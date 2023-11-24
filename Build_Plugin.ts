//Imports
import os from "os";
import fs from "fs";
import { zip } from "zip-a-folder";

//Log Start of Build
console.log("-=+=- Building the Plugin");

//Constants
const Openplanet_Plugins_Directory = `${os.homedir()}/openplanetnext/Plugins`;
const Source_Directory = `${process.cwd()}/src`;

//Check if the Openplanet Plugins Folder does not exist
if (!fs.existsSync(Openplanet_Plugins_Directory))
	throw new Error(`Can not Find Openplanet Plugins at -- ${Openplanet_Plugins_Directory}`);

//Zip the Contents of the Source Directory
zip(Source_Directory, `${Openplanet_Plugins_Directory}/Predictor-DEV.op`);

//Log Successful Build
console.log(
	`\n-=+=- Plugin Built Successfully to -- ${Openplanet_Plugins_Directory}/Predictor-DEV.op`
);
