//Imports
import { homedir } from 'os';
import { cpSync, existsSync } from 'fs';
import { zip } from 'zip-a-folder';
import { rimraf } from 'rimraf';

//Log Start of Build
console.log('-=+=- Building the Plugin');

//Constants
const openplanetPluginsDirectory = `${homedir()}/openplanetnext/Plugins`;
const sourceDirectory = `${process.cwd()}/plugin-src`;

//Check if the Openplanet Plugins Folder does not exist
if (!existsSync(openplanetPluginsDirectory)) throw new Error(`Can not Find Openplanet Plugins at -- ${openplanetPluginsDirectory}`);

// Delete the Old Plugin using rimraf
await rimraf(`${openplanetPluginsDirectory}/PredictorDev`);

//Copy over the Dev Plugin to the Openplanet Plugins Folder
cpSync(`${sourceDirectory}`, `${openplanetPluginsDirectory}/PredictorDev`, { recursive: true });

//Zip the Contents of the Source Directory to the Releases Directory
zip(sourceDirectory, `${process.cwd()}/Releases/Predictor.op`);

//Log Successful Build
console.log(
	`
	\n-=+=- Plugin Built Successfully to -- ${openplanetPluginsDirectory}/Predictor-DEV.op
	\n-=+=- Plugin Built Successfully to -- ${process.cwd()}/Releases/Predictor.op
	`,
);
