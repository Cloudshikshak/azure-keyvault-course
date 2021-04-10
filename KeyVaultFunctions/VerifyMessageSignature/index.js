const { DefaultAzureCredential } = require("@azure/identity");
const { KeyClient, CryptographyClient } = require("@azure/keyvault-keys");
const crypto = require("crypto")

// https://docs.microsoft.com/en-us/javascript/api/overview/azure/key-vault-index?view=azure-node-latest
// https://docs.microsoft.com/en-us/javascript/api/@azure/keyvault-keys/?view=azure-node-latest

module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    if(req.body && req.body.message)
    {
        if(req.body.messageSignature)
        {
            const credential = new DefaultAzureCredential();

            const keyVaultName = "<KEYVAULT_NAME>";
            const keyVaultURI = "https://" + keyVaultName + ".vault.azure.net";

            const keyName = "SigningKey";
            
            // keyvault-keys package: https://docs.microsoft.com/en-us/javascript/api/@azure/keyvault-keys/?view=azure-node-latest
            const clientKey = new KeyClient(keyVaultURI, credential);
            
            const keyVaultKey = await clientKey.getKey(keyName);

            let clientCrypto = new CryptographyClient(keyVaultKey, credential);

            // create hash of message using crypto library
            const message = req.body.message;
            const messageSignature = req.body.messageSignature
        
            const messageSignatureBuffer = Buffer.from(messageSignature, 'hex')
        
            // Get hash of the message
            const myHash = crypto.createHash("sha256").update(message).digest()

            const verifyResult = await clientCrypto.verify("RS256", myHash, messageSignatureBuffer);
        
            context.res = {
                // status: 200, /* Defaults to 200 */
                body: {"verifyResult" : verifyResult }
            };
        }
        else {
            context.res = {
                status: 400,
                body: "Parameter missing: Message Signature"
            };
        }   
        
    }
    else {
        context.res = {
            status: 400,
            body: "Parameter missing: Message"
        };
    }   
    
}