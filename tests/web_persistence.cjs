const assert=require('node:assert/strict');
const vm=require('node:vm');
const fs=require('node:fs');
const source=fs.readFileSync('scripts/web/persistence.js','utf8');
const delay=ms=>new Promise(r=>setTimeout(r,ms));
async function until(predicate){const start=Date.now();while(!predicate()&&Date.now()-start<2000)await delay(2);assert.ok(predicate(),'Asynchronous confirmation completed');}
function environment(entries,options={}){
  const result={completed:[],closes:0,reads:0};
  const window={};
  const context={window,TextDecoder,clearTimeout,setTimeout:(f,ms)=>setTimeout(f,Math.min(ms,2)),performance:{now:()=>options.timeout?21001*(result.clock++||0):Date.now()},indexedDB:{
    open(){
      const request={};
      setTimeout(()=>{
        if(options.denied){request.onerror();return;}
        request.result={
          objectStoreNames:['FILE_DATA'],
          close(){result.closes++;},
          transaction(){
            const transaction={objectStore(){return {get(path){
              const read={};
              setTimeout(()=>{
                result.reads++;
                const value=typeof entries==='function'?entries(path,result.reads):entries[path];
                read.result=value===undefined?undefined:{contents:new TextEncoder().encode(value)};
                read.onsuccess();
                setTimeout(()=>transaction.oncomplete(),0);
              },0);
              return read;
            }}}};
            return transaction;
          }
        };
        request.onsuccess();
      },0);
      return request;
    }
  }};
  result.clock=0;
  result.run=(text,generation=1)=>{
    window.__soloSaveRequest={path:'/userfs/island-v1.json',text,generation};
    window.__soloSaveComplete=(...args)=>result.completed.push(args);
    vm.runInNewContext(source,context);
  };
  return result;
}
(async()=>{
  let e=environment({'/userfs/island-v1.json':'current'});
  e.run('current');
  await until(()=>e.completed.length>0);
  assert.deepEqual(e.completed,[[1,true,'Saved to browser storage.']]);
  assert.equal(e.closes,1);
  e=environment((path,reads)=>reads<3?'old':'new');
  e.run('new');
  await until(()=>e.completed.length>0);
  assert.equal(e.reads,3);
  assert.equal(e.completed[0][1],true,'Stale generations cannot acknowledge a new save');
  e=environment({}, {timeout:true});
  e.run('new');
  await until(()=>e.completed.length>0);
  assert.equal(e.completed[0][1],false,'Unconfirmed persistence must fail explicitly');
  assert.equal(e.closes,1);
  e=environment((path,reads)=>'new');
  e.run('old',1);
  await until(()=>e.reads>0);
  e.run('new',2);
  await until(()=>e.completed.length>0);
  assert.equal(e.completed.length,1,'Superseded confirmations cannot call a stale owner');
  assert.equal(e.completed[0][0],2);
  e=environment({}, {denied:true});
  e.run('new');
  await until(()=>e.completed.length>0);
  assert.equal(e.completed[0][1],false,'Denied IndexedDB is reported');
  console.log('WEB_PERSISTENCE_TESTS passed=5');
})().catch(e=>{console.error(e);process.exitCode=1;});
