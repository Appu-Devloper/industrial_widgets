// Build example with --profile --dart-define=DEMO=true and serve build/web.
// npm install --prefix /tmp/industrial-browser playwright
// /tmp/industrial-browser/node_modules/.bin/playwright install ffmpeg
// NODE_PATH=/tmp/industrial-browser/node_modules node tool/record_demo.cjs
const {chromium}=require('playwright');
const fs=require('node:fs');
(async()=>{
 const browser=await chromium.launch({channel:'chrome',headless:true});
 const context=await browser.newContext({viewport:{width:1440,height:1280},deviceScaleFactor:1,
   recordVideo:{dir:'doc/assets/recordings',size:{width:1440,height:1280}}});
 const page=await context.newPage();
 page.on('pageerror',e=>console.error(e));
 await page.goto(process.env.URL || 'http://localhost:8765');
 await page.locator('flutter-view').waitFor();
 await page.waitForTimeout(2000);
 await page.screenshot({path:'doc/assets/demo-start.png'});
 await page.waitForTimeout(18000);
 await page.screenshot({path:'doc/assets/demo-end.png'});
 const video=page.video();
 await context.close();
 await video.saveAs('doc/assets/factory-monitor-showcase.webm');
 fs.rmSync('doc/assets/recordings',{recursive:true});
 await browser.close();
 console.log('Saved factory-monitor-showcase.webm and start/end stills.');
})();
