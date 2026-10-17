// Read-only confirmation of Godot's own asynchronous IndexedDB write.
// Uses browser IndexedDB APIs; it does not write the save or call private engine APIs.
(function (request, complete) {
  if (window.__soloSaveJob) window.__soloSaveJob.cancel();
  let stopped=false, database=null, timer=null;
  const finish=(ok,message)=>{
    if(stopped) return;
    stopped=true; clearTimeout(timer);
    if(database) database.close();
    complete(request.generation,ok,message);
  };
  const job={cancel(){stopped=true;clearTimeout(timer);if(database)database.close();}};
  window.__soloSaveJob=job;
  const started=performance.now();
  const open=indexedDB.open('/userfs');
  open.onupgradeneeded=()=>{open.transaction.abort();};
  open.onerror=()=>finish(false,'Browser save storage could not be opened.');
  open.onblocked=()=>finish(false,'Browser save storage is blocked by another tab.');
  open.onsuccess=()=>{
    database=open.result;
    if(stopped){database.close();return;}
    const poll=()=>{
      if(stopped) return;
      if(performance.now()-started>20000){finish(false,'Browser storage did not confirm the latest save. Download a backup.');return;}
      const stores=Array.from(database.objectStoreNames);
      if(!stores.length){finish(false,'Browser save storage has no file store.');return;}
      let remaining=stores.length, matched=false;
      const transaction=database.transaction(stores,'readonly');
      for(const name of stores){
        const read=transaction.objectStore(name).get(request.path);
        read.onsuccess=()=>{
          const bytes=read.result?.contents;
          if(bytes){
            try {if(new TextDecoder().decode(bytes)===request.text)matched=true;}catch(error){}
          }
          remaining--;
        };
        read.onerror=()=>{remaining--;};
      }
      transaction.oncomplete=()=>{
        if(stopped)return;
        if(matched&&remaining===0)finish(true,'Saved to browser storage.');
        else timer=setTimeout(poll,100);
      };
      transaction.onerror=()=>finish(false,'Browser save confirmation failed. Download a backup.');
    };
    poll();
  };
})(window.__soloSaveRequest, window.__soloSaveComplete);
