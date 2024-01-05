//Usage: node minify.js [indir] [outdir]
html_minifier_terser = require('html-minifier-terser')
terser = require('terser')
fs = require('fs')
path = require('path')
args = process.argv.slice(2)
fs.readdirSync(args[0]).forEach(async function(file) {
    var content;
    switch(path.extname(file)) {
        case '.html':
            try {
                content = await html_minifier_terser.minify(fs.readFileSync(args[0] + '/' + file,'utf8'),{
                    caseSensitive :true,
                    collapseBooleanAttributes: true,
                    collapseWhitespace: true,
                    collapseInlineTagWhitespace: true,
                    decodeEntities: true,
                    minifyCSS: true,
                    minifyJS: true,
                    minifyURLs: true,
                    removeComments: true,
                    removeEmptyAttributes: true,
                    removeEmptyElements: true,
                    removeRedundantAttributes: true,
                    removeScriptTypeAttributes: true,
                    removeStyleLinkTypeAttributes: true,
                    removeOptionalTags: true,
                })
            }
            catch(err) {
                console.log(err, " when minifying ", file)
            }
            break
        case '.js':
            try {
                content = (await terser.minify(fs.readFileSync(args[0] + '/' + file,'utf8'))).code
            }
            catch(err) {
                console.log(err, " when minifying ", file)
            }
            break
    }
    if(content !== undefined) {
        fs.mkdirSync(args[1],{ recursive: true })
        fs.writeFileSync(args[1] + '/' + file, content)
    }
})
