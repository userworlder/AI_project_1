const fs = require('fs');
const path = require('path');
const os = require('os');

// Polyfill for Node.js built-in zip support
// DOCX files are ZIP archives. We'll use a lightweight approach.

async function main() {
  console.log('Starting docx update...');

  const files = [
    { src: 'AI伴学平台_项目介绍文档.docx', dst: '灵思AI学伴_项目介绍文档.docx' },
    { src: 'AI伴学平台_接口文档.docx', dst: '灵思AI学伴_接口文档.docx' }
  ];

  for (const f of files) {
    const srcPath = path.join(__dirname, f.src);
    const dstPath = path.join(__dirname, f.dst);

    console.log(`Processing: ${f.src}`);

    if (!fs.existsSync(srcPath)) {
      console.error(`File not found: ${srcPath}`);
      continue;
    }

    // Read as text and replace
    let content = fs.readFileSync(srcPath, 'utf8');

    // Replace all occurrences
    const replacements = [
      [/AI伴学平台/g, '灵思·AI学伴'],
      [/AI 伴学平台/g, '灵思·AI学伴'],
      [/AI伴学/g, '灵思·AI学伴'],
      [/AI 伴学/g, '灵思·AI学伴'],
    ];

    for (const [pattern, replacement] of replacements) {
      const matches = content.match(pattern);
      if (matches) {
        console.log(`  Replacing ${matches.length} occurrences of "${pattern}"`);
        content = content.replace(pattern, replacement);
      }
    }

    // Write to new file
    fs.writeFileSync(dstPath, content, 'utf8');
    console.log(`  Written to: ${f.dst}`);
  }

  console.log('Done!');
}

main().catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
