## NodeJS 多线程

ref: [Execute a command line binary with Node.js](https://stackoverflow.com/questions/20643470/execute-a-command-line-binary-with-node-js)

For even newer version of Node.js (v8.1.4), the events and calls are similar or identical to older versions, but it's encouraged to use the standard newer language features. Examples:

For buffered, non-stream formatted output (you get it all at once), use `child_process.exec`:

```javascript
const { exec } = require('child_process');
exec('cat *.js bad_file | wc -l', (err, stdout, stderr) => {
  if (err) {
    // node couldn't execute the command
    return;
  }

  // the *entire* stdout and stderr (buffered)
  console.log(`stdout: ${stdout}`);
  console.log(`stderr: ${stderr}`);
});
You can also use it with Promises:

const util = require('util');
const exec = util.promisify(require('child_process').exec);

async function ls() {
  const { stdout, stderr } = await exec('ls');
  console.log('stdout:', stdout);
  console.log('stderr:', stderr);
}
ls();
```

If you wish to receive the data gradually in chunks (output as a stream), use child_process.spawn:

```js
const { spawn } = require('child_process');
const child = spawn('ls', ['-lh', '/usr']);

// use child.stdout.setEncoding('utf8'); if you want text chunks
child.stdout.on('data', (chunk) => {
  // data from standard output is here as buffers
});

// since these are streams, you can pipe them elsewhere
child.stderr.pipe(dest);

child.on('close', (code) => {
  console.log(`child process exited with code ${code}`);
});
```

Both of these functions have a synchronous counterpart. An example for `child_process.execSync`:

```js
const { execSync } = require('child_process');
// stderr is sent to stderr of parent process
// you can set options.stdio if you want it to go elsewhere
let stdout = execSync('ls');
```

As well as `child_process.spawnSync`:

```js
const { spawnSync} = require('child_process');
const child = spawnSync('ls', ['-lh', '/usr']);

console.log('error', child.error);
console.log('stdout ', child.stdout);
console.log('stderr ', child.stderr);
```

Note: The following code is still functional, but is primarily targeted at users of ES5 and before.

The module for spawning child processes with Node.js is well documented in the documentation (v5.0.0). To execute a command and fetch its complete output as a buffer, use child_process.exec:

```js
var exec = require('child_process').exec;
var cmd = 'prince -v builds/pdf/book.html -o builds/pdf/book.pdf';

exec(cmd, function(error, stdout, stderr) {
  // command output is in stdout
});
If you need to use handle process I/O with streams, such as when you are expecting large amounts of output, use child_process.spawn:

var spawn = require('child_process').spawn;
var child = spawn('prince', [
  '-v', 'builds/pdf/book.html',
  '-o', 'builds/pdf/book.pdf'
]);

child.stdout.on('data', function(chunk) {
  // output will be here in chunks
});

// or if you want to send output elsewhere
child.stdout.pipe(dest);
```

If you are executing a file rather than a command, you might want to use `child_process.execFile`, which parameters which are almost identical to spawn, but has a fourth callback parameter like exec for retrieving output buffers. That might look a bit like this:

```js
var execFile = require('child_process').execFile;
execFile(file, args, options, function(error, stdout, stderr) {
  // command output is in stdout
});
```

As of v0.11.12, Node now supports synchronous spawn and exec. All of the methods described above are asynchronous, and have a synchronous counterpart. Documentation for them can be found here. While they are useful for scripting, do note that unlike the methods used to spawn child processes asynchronously, the synchronous methods do not return an instance of ChildProcess.