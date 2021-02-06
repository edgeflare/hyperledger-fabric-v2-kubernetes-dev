import { Wallets, X509Identity } from 'fabric-network';
import * as FabricCAServices from 'fabric-ca-client';
import * as path from 'path';
import * as fs from 'fs';
import { RegisterUserDto } from 'src/dto';

export const registerUser = async (user: RegisterUserDto) => {
  try {
    // Load the network configuration
    const ccpPath = path.resolve(__dirname, process.env.HLF_CCP_PATH);
    const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

    // Create a new CA client for interacting with the CA.
    const caURL = ccp.certificateAuthorities[process.env.HLF_ORG_CA].url;
    const ca = new FabricCAServices(caURL);

    // Create a new file system based wallet for managing identities.
    const walletPath = path.join(process.cwd(), 'wallet');
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    console.log(`Wallet path: ${walletPath}`);

    // Check to see if we've already enrolled the user.
    const userIdentity = await wallet.get(user.name);
    if (userIdentity) {
      console.log(`An identity for the user ${user.name} already exists in the wallet`);
      return;
    }

    // Check to see if we've already enrolled the admin user.
    const adminIdentity = await wallet.get('admin');
    if (!adminIdentity) {
      console.log('An identity for the admin user "admin" does not exist in the wallet');
      console.log('Run the enrollAdmin.ts application before retrying');
      return;
    }

    // Build a user object for authenticating with the CA
    const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
    const adminUser = await provider.getUserContext(adminIdentity, 'admin');

    // Register the user, enroll the user, and import the new identity into the wallet.
    const secret = await ca.register({ affiliation: user.affiliation, enrollmentID: user.name, role: 'client' }, adminUser);
    const enrollment = await ca.enroll({ enrollmentID: user.name, enrollmentSecret: secret });
    const x509Identity: X509Identity = {
      credentials: {
        certificate: enrollment.certificate,
        privateKey: enrollment.key.toBytes(),
      },
      mspId: process.env.HLF_MSPID,
      type: 'X.509',
    };
    await wallet.put(user.name, x509Identity);
    return `Successfully registered and enrolled user ${user.name} and imported it into the wallet`;

  } catch (error) {
    console.error(`Failed to register user ${user.name}: ${error}`);
    process.exit(1);
  }
}
