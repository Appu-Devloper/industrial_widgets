// npm install --prefix /tmp/industrial-browser playwright
// NODE_PATH=/tmp/industrial-browser/node_modules node tool/browser_check.cjs
const {chromium}=require('playwright');
const fs=require('node:fs');
const os=require('node:os');
(async()=>{
 const browser=await chromium.launch({channel:'chrome',headless:true});
 const page=await browser.newPage({viewport:{width:1440,height:1280},deviceScaleFactor:1});
 const errors=[];page.on('pageerror',e=>errors.push(String(e)));
 await page.goto(process.env.URL || 'http://localhost:8765');
 await page.waitForTimeout(3000);
 const cdp=await page.context().newCDPSession(page);
 await cdp.send('Performance.enable');
 const before=await cdp.send('Performance.getMetrics');
 const frames=await page.evaluate(()=>new Promise(resolve=>{
   const intervals=[];let previous=null,start=null;
   function frame(now){if(start===null)start=now;if(previous!==null)intervals.push(now-previous);previous=now;
     if(now-start<20000)requestAnimationFrame(frame);else resolve(intervals);}
   requestAnimationFrame(frame);
 }));
 const after=await cdp.send('Performance.getMetrics');
 frames.sort((a,b)=>a-b);
 const metric=(set,name)=>set.metrics.find(m=>m.name===name).value;
 const report={browser:await browser.version(),platform:os.platform(),architecture:os.arch(),cpu:os.cpus()[0].model,
   viewport:'1440 × 1280',mode:'Flutter profile, CanvasKit, headless Chrome',widgets:8,series:2,retainedPoints:4000,visiblePointsApproximately:2402,updateHz:10,
   rafSamples:frames.length,rafMedianMs:frames[Math.floor(frames.length*.5)],rafP95Ms:frames[Math.floor(frames.length*.95)],rafMaxMs:frames.at(-1),rafIntervalsOver33ms:frames.filter(n=>n>33).length,
   browserTaskSeconds:metric(after,'TaskDuration')-metric(before,'TaskDuration'),jsHeapUsedBytes:metric(after,'JSHeapUsedSize'),errors};
 fs.writeFileSync('doc/profile-results.json',JSON.stringify(report,null,2)+'\n');console.log(report);
 await page.getByRole('button',{name:'Enable accessibility',exact:true}).evaluate(el=>el.click());
 await page.waitForTimeout(300);
 console.log((await page.locator('body').ariaSnapshot()).slice(0,16000));
 await page.getByRole('button',{name:'Pause',exact:true}).click();
 await page.waitForTimeout(500);
 await page.screenshot({path:'doc/assets/factory-monitor-dark.png'});
 await page.getByRole('button',{name:'Switch theme',exact:true}).click();
 await page.waitForTimeout(500);await page.screenshot({path:'doc/assets/factory-monitor-light.png'});
 await page.setViewportSize({width:390,height:844});await page.waitForTimeout(500);
 await page.screenshot({path:'doc/assets/factory-monitor-mobile.png'});
 console.log('Browser checks and screenshots complete. Errors:',errors);
 await browser.close();
})();
