const {chromium} = require('playwright');
const assert = require('node:assert/strict');
(async () => {
  const browser = await chromium.launch({headless:true,args:['--use-angle=swiftshader','--enable-unsafe-swiftshader']});
  const context = await browser.newContext({viewport:{width:1280,height:720}});
  const page = await context.newPage();
  const errors = [];
  page.on('pageerror', e => errors.push(e.message));
  page.on('console', msg => {
    const text = msg.text();
    if (/SCRIPT ERROR:|Parse Error:|ERROR:.*(shader|script|resource)/i.test(text)) errors.push(text);
    if (text.includes('SOLOSURVIVAL')) console.log(text);
  });
  try {
    await page.goto('http://127.0.0.1:8060/index.html',{waitUntil:'domcontentloaded'});
    await page.waitForFunction(() => window.__soloSurvivalState?.ready,{timeout:120000});
    assert.ok((await page.evaluate(() => window.__soloSurvivalState.nodes))>100);
    await page.keyboard.press('Enter');
    await page.waitForFunction(() => window.__soloSurvivalState.playing);
    await page.waitForTimeout(1800);
    // The guaranteed tree is directly in front of the initial camera.
    await page.mouse.click(640,360);
    await page.waitForTimeout(900);
    await page.mouse.click(640,360);
    await page.waitForFunction(() => window.__soloSurvivalState.wood>0,{timeout:15000});
    const before = await page.evaluate(() => window.__soloSurvivalState);
    await page.keyboard.down('KeyD');
    await page.waitForTimeout(1100);
    await page.keyboard.up('KeyD');
    await page.waitForTimeout(400);
    const after = await page.evaluate(() => window.__soloSurvivalState);
    assert.ok(Math.abs(after.position[0]-before.position[0])>1,'Keyboard movement changes position');
    assert.ok(after.position[1]>after.ground-1 && after.position[1]<after.ground+3,'World collision holds');
    await page.keyboard.press('F5');
    await page.waitForFunction(() => window.__soloSurvivalState.saves>0);
    const saved = await page.evaluate(() => window.__soloSurvivalState);
    await page.screenshot({path:'build/browser-smoke.png'});
    await page.reload({waitUntil:'domcontentloaded'});
    await page.waitForFunction(() => window.__soloSurvivalState?.ready,{timeout:120000});
    const restored = await page.evaluate(() => window.__soloSurvivalState);
    assert.ok(restored.wood>=saved.wood,'Inventory restored across browser reload');
    assert.ok(Math.abs(restored.position[0]-saved.position[0])<0.5,'Position restored across browser reload');
    assert.deepEqual(errors,[],'No script/runtime errors');
    console.log('BROWSER_SMOKE_PASS '+JSON.stringify({before,after,saved,restored}));
  } finally {
    if (errors.length) console.error(errors.join('\n'));
    await context.close();
    await browser.close();
  }
})().catch(e => {console.error(e);process.exitCode=1;});
