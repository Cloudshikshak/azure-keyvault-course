const { DefaultAzureCredential } = require("@azure/identity");
const { KeyClient, CryptographyClient } = require("@azure/keyvault-keys");
const { SecretClient } = require("@azure/keyvault-secrets");
const crypto = require("crypto")

module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    if(req.body && req.body.message)
    {
        const keyVaultName = "<KEYVAULT_NAME>";
        const keyVaultURI = "https://" + keyVaultName + ".vault.azure.net";
    
        const credential = new DefaultAzureCredential();
    
        // Create AES Key
        const key = crypto.randomBytes(32); 
        
        context.log("Generated AES Key: " + JSON.stringify(key))
    
        const iv = crypto.randomBytes(16)
    
        // create cipher object to encrypt data
        const inputEncoding = 'utf8';
        const outputEncoding = 'hex';
        const algorithm = 'aes256'
        
        // Documentation: https://nodejs.org/api/crypto.html#crypto_crypto_createcipheriv_algorithm_key_iv_options
        const cipher = crypto.createCipheriv(algorithm, key, iv)
        let encrypted = cipher.update(req.body.message, inputEncoding, outputEncoding)
        encrypted += cipher.final(outputEncoding)
        // Append IV to create final cipher
        let ciphertext = iv.toString(outputEncoding) + ':' + encrypted
        // Encryption completed with symmetric AES key

        // Protect the AES key by wrapping it with Key Encryption Key (Asymmetric key)
        const clientKey = new KeyClient(keyVaultURI, credential);
        
        const keyName = "KEK";
        const keyVaultKey = await clientKey.getKey(keyName);
    
        let clientCrypto = new CryptographyClient(keyVaultKey, credential);
      
        // Wrap the symmetric key 'key' with Key Encryption Key 'KEK'
        const wrapResult = await clientCrypto.wrapKey("RSA-OAEP", key);
        
        // Convert to hex to store it as secret
        let wrappedKey = wrapResult.result.toString('hex')
        
        context.log("Wrapped AES Key: " + wrappedKey)
    
        // Optional: Store the wrapped key as secret
        const secretName = "WrappedSymmetricKey";
        const clientSecret = new SecretClient(keyVaultURI, credential);
        // Set the secret with wrapped key
        await clientSecret.setSecret(secretName, wrappedKey);
    
        context.res = {
            // status: 200, /* Defaults to 200 */
            body: { "cipher" : ciphertext }
        };
    }
    else {
        context.res = {
            status: 400,
            body: "Parameter missing: Message"
        };
    }
    
}