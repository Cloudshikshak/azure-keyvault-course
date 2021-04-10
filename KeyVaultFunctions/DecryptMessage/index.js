const { DefaultAzureCredential } = require("@azure/identity");
const { KeyClient, CryptographyClient } = require("@azure/keyvault-keys");
const { SecretClient } = require("@azure/keyvault-secrets");
const crypto = require("crypto")

module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    if(req.body && req.body.cipher)
    {
        const keyVaultName = "<KEYVAULT_NAME>";
        const keyVaultURI = "https://" + keyVaultName + ".vault.azure.net";

        const credential = new DefaultAzureCredential();

        // Get wrapped key from secret
        const secretName = "WrappedSymmetricKey";
        const clientSecret = new SecretClient(keyVaultURI, credential);

        wrappedKey = await clientSecret.getSecret(secretName);

        // Convert hex to buffer
        const wrappedKeyBuff = Buffer.from(wrappedKey.value, 'hex')

        // Unwrap key
        const clientKey = new KeyClient(keyVaultURI, credential);
    
        const keyName = "KEK";
        const keyVaultKey = await clientKey.getKey(keyName);

        let clientCrypto = new CryptographyClient(keyVaultKey, credential);

        const unwrappedKeyResult = await clientCrypto.unwrapKey("RSA-OAEP", wrappedKeyBuff);
        const unwrappedKey = unwrappedKeyResult.result
        context.log("Unwrapped AES key: " + JSON.stringify(unwrappedKey))

        // Decrypt cipher with unwrapped AES key
        const algorithm = 'aes256'
        const outputEncoding = 'utf8';
        const inputEncoding = 'hex';

        // Documentation: https://nodejs.org/api/crypto.html#crypto_crypto_createdecipheriv_algorithm_key_iv_options
        let components = req.body.cipher.split(':');
        const iv_from_ciphertext = Buffer.from(components.shift(), inputEncoding);
        let decipher = crypto.createDecipheriv(algorithm, unwrappedKey, iv_from_ciphertext);
        let decipheredMessage = decipher.update(components.join(':'), inputEncoding, outputEncoding);
        decipheredMessage += decipher.final(outputEncoding);

        context.res = {
            // status: 200, /* Defaults to 200 */
            body: { "decryptedMessage": decipheredMessage}
        };
    }
    else {
        context.res = {
            status: 400,
            body: "Parameter missing: Cipher"
        };
    }
}