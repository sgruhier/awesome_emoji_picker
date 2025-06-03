const fs = require('fs');
const path = require('path');
const https = require('https');

const version = process.argv[2] || 'latest';
main(version);

async function main(version) {
  const text = await getTestFile(version);

  console.log(`Format text to json...`);
  console.log(`  text: ${text.length} bytes`);
  const collected = text
    .trim()
    .split('\n')
    .reduce(
      (accu, line) => {
        if (line.startsWith('# group: ')) {
          console.log(`  Processing ${line.substr(2)}...`);
          accu.group = line.substr(9);
        } else if (line.startsWith('# subgroup: ')) {
          accu.subgroup = line.substr(12);
        } else if (line.startsWith('#')) {
          accu.comments = accu.comments + line + '\n';
        } else {
          const meta = parseLine(line);
          if (meta) {
            meta.category = `${accu.group} (${accu.subgroup})`;
            meta.group = accu.group;
            meta.subgroup = accu.subgroup;
            accu.full.push(meta);
            accu.compact.push(meta.char);
          } else {
            accu.comments = accu.comments.trim() + '\n\n';
          }
        }
        return accu;
      },
      { comments: '', full: [], compact: [] }
    );

  console.log(`Processed emojis: ${collected.full.length}`);

  console.log('Write file: emoji.json, emoji-compact.json \n');
  await writeFiles(collected);

  console.log(collected.comments);
}

async function getTestFile(version) {
  const url = `https://unicode.org/Public/emoji/${version}/emoji-test.txt`;
  console.log(url);

  process.stdout.write(`Fetch emoji-test.txt (${version})`);
  return new Promise((resolve, reject) => {
    const fetchUrl = (requestUrl) => {
      https
        .get(requestUrl, (res) => {
          // Handle redirects
          if (res.statusCode === 301 || res.statusCode === 302) {
            const redirectUrl = res.headers.location;
            console.log(`\nRedirecting to: ${redirectUrl}`);
            return fetchUrl(redirectUrl);
          }

          if (res.statusCode !== 200) {
            return reject(new Error(`HTTP ${res.statusCode}: ${res.statusMessage}`));
          }

          let text = '';
          res.setEncoding('utf8');
          res.on('data', (chunk) => {
            process.stdout.write('.');
            text += chunk;
          });
          res.on('end', () => {
            process.stdout.write('\n');
            resolve(text);
          });
          res.on('error', reject);
        })
        .on('error', reject);
    };

    fetchUrl(url);
  });
}

function parseLine(line) {
  const data = line.trim().split(/\s+[;#] /);

  if (data.length !== 3) {
    return null;
  }

  const [codes, status, charAndName] = data;
  const [, char, name] = charAndName.match(/^(\S+) E\d+\.\d+ (.+)$/);

  return { codes, char, name };
}

const rel = (...args) => path.resolve(__dirname, ...args);

function writeFiles({ full, compact }) {
  fs.writeFileSync(rel('./emoji.json'), JSON.stringify(full, null, 2), 'utf8');
  fs.writeFileSync(rel('./emoji-compact.json'), JSON.stringify(compact, null, 2), 'utf8');
}
