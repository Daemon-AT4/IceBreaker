'use strict';
// ── sg-dividers.js ── Line-break divider graphics ─────────

const DIV_W = 860, DIV_H = 44;

// ── DIVIDER A : ▓▒░ ── ICEBREAKER ── ░▒▓ (iris) ──────────
function drawDivA(canvas) {
  const W=DIV_W, H=DIV_H;
  canvas.width=W; canvas.height=H;
  const ctx=canvas.getContext('2d');
  fillBg(ctx,W,H);
  drawScanlines(ctx,W,H);

  const cx=W/2, cy=H/2;
  const textW=140, pad=20, blockW=36;

  // Full-width faint base line
  ctx.save();
  ctx.strokeStyle=rgba(C.iris,0.15); ctx.lineWidth=1;
  ctx.beginPath(); ctx.moveTo(0,cy); ctx.lineTo(W,cy); ctx.stroke();
  ctx.restore();

  // Left noise block  ▓▒░
  ctx.save();
  ctx.font='700 12px "JetBrains Mono"'; ctx.textAlign='right'; ctx.textBaseline='middle';
  ctx.fillStyle=rgba(C.iris,0.55); ctx.shadowColor=C.iris; ctx.shadowBlur=8;
  ctx.fillText('▓▒░', cx-textW/2-pad, cy);
  ctx.restore();

  // Right noise block ░▒▓
  ctx.save();
  ctx.font='700 12px "JetBrains Mono"'; ctx.textAlign='left'; ctx.textBaseline='middle';
  ctx.fillStyle=rgba(C.iris,0.55); ctx.shadowColor=C.iris; ctx.shadowBlur=8;
  ctx.fillText('░▒▓', cx+textW/2+pad, cy);
  ctx.restore();

  // Left dashed line
  ctx.save();
  ctx.setLineDash([4,6]); ctx.strokeStyle=rgba(C.iris,0.4); ctx.lineWidth=1;
  ctx.shadowColor=C.iris; ctx.shadowBlur=6;
  ctx.beginPath(); ctx.moveTo(blockW+8,cy); ctx.lineTo(cx-textW/2-pad-28,cy); ctx.stroke();
  ctx.restore();

  // Right dashed line
  ctx.save();
  ctx.setLineDash([4,6]); ctx.strokeStyle=rgba(C.iris,0.4); ctx.lineWidth=1;
  ctx.shadowColor=C.iris; ctx.shadowBlur=6;
  ctx.beginPath(); ctx.moveTo(cx+textW/2+pad+28,cy); ctx.lineTo(W-blockW-8,cy); ctx.stroke();
  ctx.restore();

  // Center text — ICEBREAKER
  glowText(ctx,'ICEBREAKER',cx,cy,{
    color:C.phosphor, size:13, weight:700,
    outerGlow:14, innerGlow:4,
  });

  // End dots
  [14,W-14].forEach(x=>{
    ctx.save(); ctx.fillStyle=C.iris; ctx.shadowColor=C.iris; ctx.shadowBlur=10;
    ctx.beginPath(); ctx.arc(x,cy,3,0,Math.PI*2); ctx.fill(); ctx.restore();
  });
}

// ── DIVIDER B : Circuit trace with PCB nodes (cyan) ────────
function drawDivB(canvas) {
  const W=DIV_W, H=36;
  canvas.width=W; canvas.height=H;
  const ctx=canvas.getContext('2d');
  fillBg(ctx,W,H);
  drawScanlines(ctx,W,H);

  const cy=H/2;
  const rand=makePRNG(99);
  const nodeXs=[60,180,310,430,W/2,W-430,W-310,W-180,W-60];

  // Base line
  ctx.save();
  ctx.strokeStyle=rgba(C.cyan,0.25); ctx.lineWidth=1;
  ctx.shadowColor=C.cyan; ctx.shadowBlur=6;
  ctx.beginPath(); ctx.moveTo(0,cy); ctx.lineTo(W,cy); ctx.stroke();
  ctx.restore();

  // Junction lines & nodes
  nodeXs.forEach((x,i)=>{
    const h=4+rand()*8;
    ctx.save();
    ctx.strokeStyle=rgba(C.cyan,0.5); ctx.lineWidth=1;
    ctx.shadowColor=C.cyan; ctx.shadowBlur=8;
    ctx.beginPath(); ctx.moveTo(x,cy-h); ctx.lineTo(x,cy+h); ctx.stroke();
    ctx.fillStyle=i===Math.floor(nodeXs.length/2)?C.phosphor:C.cyan;
    ctx.shadowColor=ctx.fillStyle; ctx.shadowBlur=12;
    ctx.beginPath(); ctx.arc(x,cy,i===Math.floor(nodeXs.length/2)?4:2.5,0,Math.PI*2); ctx.fill();
    ctx.restore();
  });

  // Short horizontal accent segments
  [[0,44],[W-44,W]].forEach(([x1,x2])=>{
    ctx.save(); ctx.strokeStyle=rgba(C.cyan,0.6); ctx.lineWidth=1.5;
    ctx.shadowColor=C.cyan; ctx.shadowBlur=10;
    ctx.beginPath(); ctx.moveTo(x1,cy); ctx.lineTo(x2,cy); ctx.stroke();
    ctx.restore();
  });

  // End caps
  [0,W].forEach(x=>{
    ctx.save(); ctx.strokeStyle=rgba(C.cyan,0.7); ctx.lineWidth=1.5;
    ctx.shadowColor=C.cyan; ctx.shadowBlur=10;
    const dir=x===0?1:-1;
    ctx.beginPath(); ctx.moveTo(x,cy-8); ctx.lineTo(x+dir*10,cy); ctx.lineTo(x,cy+8); ctx.stroke();
    ctx.restore();
  });
}

// ── DIVIDER C : Double neon rule + diamond (rose) ──────────
function drawDivC(canvas) {
  const W=DIV_W, H=32;
  canvas.width=W; canvas.height=H;
  const ctx=canvas.getContext('2d');
  fillBg(ctx,W,H);
  drawScanlines(ctx,W,H);

  const cy=H/2;
  const fade=(x1,x2,col,alpha)=>{
    const g=ctx.createLinearGradient(x1,0,x2,0);
    g.addColorStop(0,'rgba(0,0,0,0)');
    g.addColorStop(.15,rgba(col,alpha));
    g.addColorStop(.85,rgba(col,alpha));
    g.addColorStop(1,'rgba(0,0,0,0)');
    return g;
  };

  // Top line
  ctx.save();
  ctx.strokeStyle=fade(0,W,C.rose,0.55); ctx.lineWidth=1;
  ctx.shadowColor=C.rose; ctx.shadowBlur=8;
  ctx.beginPath(); ctx.moveTo(0,cy-4); ctx.lineTo(W,cy-4); ctx.stroke();
  ctx.restore();

  // Bottom line
  ctx.save();
  ctx.strokeStyle=fade(0,W,C.rose,0.3); ctx.lineWidth=1;
  ctx.shadowColor=C.rose; ctx.shadowBlur=4;
  ctx.beginPath(); ctx.moveTo(0,cy+4); ctx.lineTo(W,cy+4); ctx.stroke();
  ctx.restore();

  // Center diamond
  ctx.save();
  ctx.translate(W/2,cy); ctx.rotate(Math.PI/4);
  ctx.fillStyle=C.rose; ctx.shadowColor=C.rose; ctx.shadowBlur=16;
  ctx.fillRect(-5,-5,10,10);
  ctx.restore();

  // Small flanking diamonds
  [W/2-80,W/2+80].forEach(x=>{
    ctx.save();
    ctx.translate(x,cy); ctx.rotate(Math.PI/4);
    ctx.fillStyle=rgba(C.rose,0.4); ctx.shadowColor=C.rose; ctx.shadowBlur=8;
    ctx.fillRect(-3,-3,6,6);
    ctx.restore();
  });
}

// ── DIVIDER D : Minimal phosphor rule ──────────────────────
function drawDivD(canvas) {
  const W=DIV_W, H=20;
  canvas.width=W; canvas.height=H;
  const ctx=canvas.getContext('2d');
  fillBg(ctx,W,H);

  const cy=H/2;
  const g=ctx.createLinearGradient(0,0,W,0);
  g.addColorStop(0,'rgba(0,0,0,0)');
  g.addColorStop(.08,rgba(C.phosphor,0.6));
  g.addColorStop(.5,rgba(C.phosphor,0.9));
  g.addColorStop(.92,rgba(C.phosphor,0.6));
  g.addColorStop(1,'rgba(0,0,0,0)');

  ctx.save();
  ctx.strokeStyle=g; ctx.lineWidth=1.5;
  ctx.shadowColor=C.phosphor; ctx.shadowBlur=10;
  ctx.beginPath(); ctx.moveTo(0,cy); ctx.lineTo(W,cy); ctx.stroke();
  ctx.restore();
}

// ── DIVIDER E : Dot-matrix ellipsis (amber) ────────────────
function drawDivE(canvas) {
  const W=DIV_W, H=24;
  canvas.width=W; canvas.height=H;
  const ctx=canvas.getContext('2d');
  fillBg(ctx,W,H);

  const cy=H/2, spacing=18;
  const count=Math.floor(W/spacing);
  for(let i=0;i<count;i++) {
    const x=i*spacing+spacing/2;
    const distFromCenter=Math.abs(x-W/2)/(W/2);
    const alpha=Math.max(0.04, 0.55*(1-distFromCenter*1.2));
    const r=i%6===0?2.5:1.5;
    ctx.save();
    ctx.fillStyle=rgba(C.amber,alpha);
    if(i%6===0){ctx.shadowColor=C.amber; ctx.shadowBlur=8;}
    ctx.beginPath(); ctx.arc(x,cy,r,0,Math.PI*2); ctx.fill();
    ctx.restore();
  }
}

// ── INIT ───────────────────────────────────────────────────
function initDividers() {
  drawDivA(document.getElementById('d-a'));
  drawDivB(document.getElementById('d-b'));
  drawDivC(document.getElementById('d-c'));
  drawDivD(document.getElementById('d-d'));
  drawDivE(document.getElementById('d-e'));
}

function dlDiv(id, filename) {
  const src = document.getElementById(id);
  const off = document.createElement('canvas');
  off.width = src.width; off.height = src.height;
  const map = {'d-a':drawDivA,'d-b':drawDivB,'d-c':drawDivC,'d-d':drawDivD,'d-e':drawDivE};
  map[id](off);
  const a = document.createElement('a');
  a.download = filename; a.href = off.toDataURL('image/png'); a.click();
}

async function dlAllDividers() {
  const zip = new JSZip();
  const entries = [
    ['d-a', drawDivA, 'divider-a-iris-noise.png'],
    ['d-b', drawDivB, 'divider-b-circuit-cyan.png'],
    ['d-c', drawDivC, 'divider-c-double-rose.png'],
    ['d-d', drawDivD, 'divider-d-minimal-phosphor.png'],
    ['d-e', drawDivE, 'divider-e-dotmatrix-amber.png'],
  ];
  entries.forEach(([,drawFn, name])=>{
    const c=document.createElement('canvas');
    drawFn(c);
    zip.file(name, c.toDataURL('image/png').split(',')[1], {base64:true});
  });
  const blob = await zip.generateAsync({type:'blob'});
  const a = document.createElement('a');
  a.download='icebreaker-dividers.zip'; a.href=URL.createObjectURL(blob); a.click();
}

Object.assign(window, { initDividers, dlDiv, dlAllDividers });
