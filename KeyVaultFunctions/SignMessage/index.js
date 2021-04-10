const { DefaultAzureCredential } = require("@azure/identity");
const { KeyClient, CryptographyClient } = require("@azure/keyvault-keys");
const crypto = require("crypto")

module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    if(req.body && req.body.message)
    {
        const credential = new DefaultAzureCredential();

        const keyVaultName = "<KEYVAULT_NAME>";
        const keyVaultURI = "https://" + keyVaultName + ".vault.azure.net";

        const keyName = "SigningKey";
        
        // keyvault-keys package: https://docs.microsoft.com/en-us/javascript/api/@azure/keyvault-keys/?view=azure-node-latest
        const clientKey = new KeyClient(keyVaultURI, credential);

        const keyVaultKey = await clientKey.getKey(keyName);

        let clientCrypto = new CryptographyClient(keyVaultKey, credential);

        // create hash of data using crypto library
        const message = req.body.message;

        // Get hash of the message
        // Documentation: https://nodejs.org/api/crypto.html#crypto_crypto_createhash_algorithm_options
        const myHash = crypto.createHash("sha256").update(message).digest()

        // Sign the hash using key vault key
        // Result returned as uint8array
        // Documentation: https://docs.microsoft.com/en-us/javascript/api/@azure/keyvault-keys/cryptographyclient?view=azure-node-latest#sign_SignatureAlgorithm__Uint8Array__SignOptions_
        const signedHash = await clientCrypto.sign("RS256", myHash)
        
        // Convert uint8array to hex format
        const hexBuffer = signedHash.result.toString('hex')
        
        context.res = {
            // status: 200, /* Defaults to 200 */
            body: { messageSignature :  hexBuffer }
        };
    }
    else {
        context.res = {
            status: 400,
            body: "Parameter missing: Message"
        };
    }   
    
}