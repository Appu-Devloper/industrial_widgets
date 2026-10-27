// Serve a normal release build; run with NODE_PATH pointing to Playwright.
const {chromium}=require('playwright');
(async()=>{
 const browser=await chromium.launch({channel:'chrome',headless:true});
 const page=await browser.newPage({viewport:{width:1440,height:1280},deviceScaleFactor:1});
 page.on('pageerror',e=>{throw e;});
 await page.goto(process.env.URL || 'http://localhost:8765');
 await page.waitForTimeout(2000);
 await page.getByRole('button',{name:'Enable accessibility',exact:true}).evaluate(el=>el.click());
 await page.mouse.move(1400,1250);await page.waitForTimeout(1000);
 await page.screenshot({path:'doc/assets/factory-monitor-dark.png'});
 await page.getByRole('button',{name:'Switch theme',exact:true}).click();
 await page.mouse.move(1400,1250);await page.waitForTimeout(1000);
 await page.screenshot({path:'doc/assets/factory-monitor-light.png'});
 await page.setViewportSize({width:390,height:844});await page.waitForTimeout(500);
 await page.screenshot({path:'doc/assets/factory-monitor-mobile.png'});
 await browser.close();
})();
