'use strict';

// ══ PALETTE ════════════════════════════════════════════════
const C = {
  base:    '#0a0e14',
  surface: '#191724',
  overlay: '#1f1d2e',
  phosphor:'#cbf7ad',
  cyan:    '#7ee8fa',
  amber:   '#ffb347',
  rose:    '#eb6f92',
  iris:    '#c4a7e7',
  subtle:  '#6e6a86',
  pale:    '#cbf7ed',
};

// ══ UTILS ══════════════════════════════════════════════════
function rgba(hex, a) {
  const r = parseInt(hex.slice(1,3),16);
  const g = parseInt(hex.slice(3,5),16);
  const b = parseInt(hex.slice(5,7),16);
  return `rgba(${r},${g},${b},${a})`;
}

function makePRNG(seed=42) {
  let s = seed;
  return () => { s=(s*1664525+1013904223)&0xffffffff; return (s>>>0)/0xffffffff; };
}

// ══ BACKGROUND HELPERS ═════════════════════════════════════

function fillBg(ctx, W, H, color=C.base) {
  ctx.fillStyle = color;
  ctx.fillRect(0, 0, W, H);
}

function drawScanlines(ctx, W, H) {
  ctx.save();
  for(let y=0; y<H; y+=4) {
    ctx.fillStyle = 'rgba(0,0,0,0.10)';
    ctx.fillRect(0, y, W, 2);
  }
  ctx.restore();
}

function drawHexGrid(ctx, W, H) {
  ctx.save();
  ctx.strokeStyle = rgba(C.iris, 0.04);
  ctx.lineWidth = 1;
  const sz=44, hh=sz*Math.sqrt(3);
  for(let row=-1; row<H/hh+2; row++) {
    for(let col=-1; col<W/(sz*1.5)+2; col++) {
      const x=col*sz*1.5, y=row*hh+(col%2)*hh/2;
      ctx.beginPath();
      for(let i=0;i<6;i++){
        const a=Math.PI/180*(60*i-30);
        const px=x+sz*Math.cos(a), py=y+sz*Math.sin(a);
        i===0 ? ctx.moveTo(px,py) : ctx.lineTo(px,py);
      }
      ctx.closePath();
      ctx.stroke();
    }
  }
  ctx.restore();
}

function drawHexGridTight(ctx, W, H) {
  ctx.save();
  ctx.strokeStyle = rgba(C.iris, 0.06);
  ctx.lineWidth = 1;
  const sz=22, hh=sz*Math.sqrt(3);
  for(let row=-1; row<H/hh+2; row++) {
    for(let col=-1; col<W/(sz*1.5)+2; col++) {
      const x=col*sz*1.5, y=row*hh+(col%2)*hh/2;
      ctx.beginPath();
      for(let i=0;i<6;i++){
        const a=Math.PI/180*(60*i-30);
        const px=x+sz*Math.cos(a), py=y+sz*Math.sin(a);
        i===0 ? ctx.moveTo(px,py) : ctx.lineTo(px,py);
      }
      ctx.closePath();
      ctx.stroke();
    }
  }
  ctx.restore();
}

function drawCircuits(ctx, W, H, count, rand) {
  ctx.save();
  for(let i=0; i<count; i++) {
    ctx.strokeStyle = rgba(C.iris, rand()*0.06+0.03);
    ctx.lineWidth = 1;
    let x=rand()*W, y=rand()*H;
    ctx.beginPath(); ctx.moveTo(x,y);
    for(let j=0;j<6;j++){
      const dir=Math.floor(rand()*4), dist=50+rand()*140;
      const nx=dir<2?x+(dir===0?dist:-dist):x;
      const ny=dir>=2?y+(dir===2?dist:-dist):y;
      ctx.lineTo(nx,y); ctx.lineTo(nx,ny);
      x=nx; y=ny;
    }
    ctx.stroke();
    if(rand()>0.6){
      ctx.fillStyle=rgba(C.iris,0.18);
      ctx.beginPath(); ctx.arc(x,y,2,0,Math.PI*2); ctx.fill();
    }
  }
  ctx.restore();
}

function drawDataRain(ctx, W, H, density, rand) {
  ctx.save();
  ctx.font = '10px "JetBrains Mono"';
  const glyphs = '01アイウエカキケ∂∆∇∫≡≈[]{}|~^';
  for(let y=10; y<H; y+=14) {
    for(let x=0; x<W; x+=10) {
      if(rand()<density) {
        ctx.fillStyle = rgba(C.phosphor, rand()*0.04+0.02);
        ctx.fillText(glyphs[Math.floor(rand()*glyphs.length)], x, y);
      }
    }
  }
  ctx.restore();
}

function drawVignette(ctx, W, H, strength=0.7) {
  const v = ctx.createRadialGradient(W/2,H/2,H*0.15,W/2,H/2,W*0.75);
  v.addColorStop(0,'rgba(0,0,0,0)');
  v.addColorStop(1,`rgba(0,0,0,${strength})`);
  ctx.fillStyle=v; ctx.fillRect(0,0,W,H);
}

function drawCenterGlow(ctx, W, H, cy, color, r=320, alpha=0.07) {
  const g = ctx.createRadialGradient(W/2,cy,0,W/2,cy,r);
  g.addColorStop(0,rgba(color,alpha)); g.addColorStop(1,'rgba(0,0,0,0)');
  ctx.fillStyle=g; ctx.fillRect(0,0,W,H);
}

// ══ DECORATIVE ═════════════════════════════════════════════

function drawBrackets(ctx, W, H, pad, sz, color, alpha=1) {
  ctx.save();
  ctx.strokeStyle=rgba(color,alpha); ctx.lineWidth=2;
  ctx.shadowColor=color; ctx.shadowBlur=14; ctx.lineCap='square';
  const corners=[[pad,pad,1,1],[W-pad,pad,-1,1],[pad,H-pad,1,-1],[W-pad,H-pad,-1,-1]];
  corners.forEach(([bx,by,dx,dy])=>{
    ctx.beginPath(); ctx.moveTo(bx+dx*sz,by); ctx.lineTo(bx,by); ctx.lineTo(bx,by+dy*sz); ctx.stroke();
  });
  ctx.restore();
}

function drawNixFlake(ctx, cx, cy, r, color, alpha=1) {
  ctx.save();
  ctx.globalAlpha=alpha; ctx.strokeStyle=color;
  ctx.lineWidth=Math.max(1.5,r/22); ctx.lineCap='round';
  ctx.shadowColor=color; ctx.shadowBlur=r*0.55;
  for(let i=0;i<6;i++){
    const ang=(i/6)*Math.PI*2;
    const ex=cx+Math.cos(ang)*r, ey=cy+Math.sin(ang)*r;
    ctx.beginPath(); ctx.moveTo(cx,cy); ctx.lineTo(ex,ey); ctx.stroke();
    const bLen=r*0.28, mx=cx+Math.cos(ang)*r*0.55, my=cy+Math.sin(ang)*r*0.55;
    [ang+Math.PI/4,ang-Math.PI/4].forEach(ba=>{
      ctx.beginPath(); ctx.moveTo(mx,my); ctx.lineTo(mx+Math.cos(ba)*bLen,my+Math.sin(ba)*bLen); ctx.stroke();
    });
    const ox=cx+Math.cos(ang)*r*0.82, oy=cy+Math.sin(ang)*r*0.82, bLen2=r*0.18;
    [ang+Math.PI/3.5,ang-Math.PI/3.5].forEach(ba=>{
      ctx.beginPath(); ctx.moveTo(ox,oy); ctx.lineTo(ox+Math.cos(ba)*bLen2,oy+Math.sin(ba)*bLen2); ctx.stroke();
    });
  }
  ctx.restore();
}

// ══ TEXT ═══════════════════════════════════════════════════

function glowText(ctx, text, x, y, {
  color=C.phosphor, size=80, weight=800,
  align='center', baseline='middle',
  outerGlow=60, innerGlow=15,
  chromatic=false, glowColor=null,
}={}) {
  ctx.save();
  ctx.textAlign=align; ctx.textBaseline=baseline;
  ctx.font=`${weight} ${size}px 'JetBrains Mono',monospace`;
  const gc=glowColor||color;
  if(chromatic){
    ctx.save(); ctx.globalAlpha=0.45;
    ctx.fillStyle=C.rose; ctx.shadowBlur=0; ctx.fillText(text,x-4,y+2);
    ctx.fillStyle=C.cyan; ctx.fillText(text,x+4,y-2);
    ctx.restore();
  }
  ctx.shadowColor=gc; ctx.shadowBlur=outerGlow*2.5; ctx.fillStyle=gc; ctx.fillText(text,x,y);
  ctx.shadowBlur=outerGlow; ctx.fillText(text,x,y);
  ctx.shadowBlur=innerGlow; ctx.fillStyle=color; ctx.fillText(text,x,y);
  ctx.restore();
}

function label(ctx, text, x, y, {
  color=C.subtle, size=11, weight=400,
  align='center', alpha=1, glow=false,
}={}) {
  ctx.save();
  ctx.globalAlpha=alpha; ctx.font=`${weight} ${size}px 'JetBrains Mono',monospace`;
  ctx.textAlign=align; ctx.textBaseline='middle'; ctx.fillStyle=color;
  if(glow){ctx.shadowColor=color; ctx.shadowBlur=12;}
  ctx.fillText(text,x,y);
  ctx.restore();
}

function statusBar(ctx, W, H, text) {
  ctx.save();
  const y=H-44;
  ctx.fillStyle=rgba(C.overlay,0.9); ctx.fillRect(0,y,W,44);
  ctx.strokeStyle=rgba(C.iris,0.2); ctx.lineWidth=1;
  ctx.beginPath(); ctx.moveTo(0,y); ctx.lineTo(W,y); ctx.stroke();
  ctx.fillStyle=C.phosphor; ctx.shadowColor=C.phosphor; ctx.shadowBlur=10;
  ctx.fillRect(22,y+16,8,12); ctx.shadowBlur=0;
  label(ctx,text,40,y+22,{color:C.phosphor,size:11,weight:500,align:'left',glow:true});
  label(ctx,'DAEMON-SEC // EYES ONLY',W-24,y+22,{color:rgba(C.subtle,0.8),size:10,align:'right'});
  ctx.restore();
}

function statPills(ctx, W, cy, pills) {
  const PW=130,PH=56,GAP=16;
  const TW=pills.length*PW+(pills.length-1)*GAP;
  const sx=W/2-TW/2;
  pills.forEach(({val,sub},i)=>{
    const px=sx+i*(PW+GAP);
    ctx.save();
    ctx.fillStyle=rgba(C.overlay,0.65); ctx.fillRect(px,cy,PW,PH);
    ctx.strokeStyle=rgba(C.iris,0.35); ctx.lineWidth=1;
    ctx.shadowColor=C.iris; ctx.shadowBlur=10; ctx.strokeRect(px,cy,PW,PH);
    ctx.fillStyle=rgba(C.iris,0.5); ctx.shadowBlur=6; ctx.fillRect(px,cy,PW,2);
    ctx.restore();
    label(ctx,val,px+PW/2,cy+19,{color:C.iris,size:22,weight:700,glow:true});
    label(ctx,sub,px+PW/2,cy+40,{color:C.subtle,size:9,weight:400});
  });
}

// Export to window for use by other scripts
Object.assign(window, {
  C, rgba, makePRNG,
  fillBg, drawScanlines, drawHexGrid, drawHexGridTight,
  drawCircuits, drawDataRain, drawVignette, drawCenterGlow,
  drawBrackets, drawNixFlake,
  glowText, label, statusBar, statPills,
});
