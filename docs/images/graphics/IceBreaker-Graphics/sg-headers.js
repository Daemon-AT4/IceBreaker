'use strict';
// ── sg-headers.js ── Section header graphics ──────────────

const HDR_W = 860, HDR_H = 80;

// ══ ICON FUNCTIONS (each draws ~28×28 centred at cx,cy) ════

function icoComment(ctx,cx,cy,col) {
  ctx.save(); ctx.fillStyle=col; ctx.shadowColor=col; ctx.shadowBlur=14;
  ctx.font='800 22px "JetBrains Mono"'; ctx.textAlign='center'; ctx.textBaseline='middle';
  ctx.fillText('//', cx, cy); ctx.restore();
}

function icoGlobe(ctx,cx,cy,col) {
  ctx.save(); ctx.strokeStyle=col; ctx.lineWidth=1.5; ctx.shadowColor=col; ctx.shadowBlur=10;
  ctx.beginPath(); ctx.arc(cx,cy,13,0,Math.PI*2); ctx.stroke();
  // Latitude lines
  [-5,0,5].forEach(dy=>{
    ctx.beginPath(); ctx.ellipse(cx,cy+dy,13,4,0,0,Math.PI*2); ctx.stroke();
  });
  ctx.restore();
}

function icoDoc(ctx,cx,cy,col) {
  ctx.save(); ctx.strokeStyle=col; ctx.lineWidth=1.5; ctx.shadowColor=col; ctx.shadowBlur=8;
  ctx.strokeRect(cx-10,cy-13,20,26);
  // Folded corner dog-ear
  ctx.fillStyle=rgba(col,0.6); ctx.beginPath();
  ctx.moveTo(cx+4,cy-13); ctx.lineTo(cx+10,cy-13); ctx.lineTo(cx+10,cy-7); ctx.lineTo(cx+4,cy-7); ctx.closePath(); ctx.fill();
  ctx.lineWidth=1;
  for(const y of [cy-3,cy+3,cy+9]){ ctx.beginPath(); ctx.moveTo(cx-6,y); ctx.lineTo(cx+5,y); ctx.stroke(); }
  ctx.restore();
}

function icoChecks(ctx,cx,cy,col) {
  ctx.save(); ctx.strokeStyle=col; ctx.lineWidth=1.2; ctx.shadowColor=col; ctx.shadowBlur=8;
  for(let i=0;i<3;i++) {
    const y=cy-8+i*8;
    ctx.strokeRect(cx-12,y-3.5,7,7);
    if(i<2){ ctx.fillStyle=col; ctx.fillRect(cx-10,y-1.5,3,3); }
    ctx.beginPath(); ctx.moveTo(cx-3,y); ctx.lineTo(cx+12,y); ctx.stroke();
  }
  ctx.restore();
}

function icoCrosshair(ctx,cx,cy,col) {
  ctx.save(); ctx.strokeStyle=col; ctx.lineWidth=1.5; ctx.shadowColor=col; ctx.shadowBlur=14;
  ctx.beginPath(); ctx.arc(cx,cy,13,0,Math.PI*2); ctx.stroke();
  ctx.beginPath(); ctx.arc(cx,cy,4,0,Math.PI*2); ctx.stroke();
  const g=5,l=13;
  [[cx-l,cy,cx-g,cy],[cx+g,cy,cx+l,cy],[cx,cy-l,cx,cy-g],[cx,cy+g,cx,cy+l]]
    .forEach(([x1,y1,x2,y2])=>{ctx.beginPath();ctx.moveTo(x1,y1);ctx.lineTo(x2,y2);ctx.stroke();});
  ctx.restore();
}

function icoDownArrow(ctx,cx,cy,col) {
  ctx.save(); ctx.strokeStyle=col; ctx.lineWidth=1.8; ctx.shadowColor=col; ctx.shadowBlur=10;
  ctx.beginPath(); ctx.moveTo(cx,cy-11); ctx.lineTo(cx,cy+4); ctx.stroke();
  ctx.beginPath(); ctx.moveTo(cx-8,cy-1); ctx.lineTo(cx,cy+7); ctx.lineTo(cx+8,cy-1); ctx.stroke();
  ctx.beginPath(); ctx.moveTo(cx-10,cy+7); ctx.lineTo(cx-10,cy+13); ctx.lineTo(cx+10,cy+13); ctx.lineTo(cx+10,cy+7); ctx.stroke();
  ctx.restore();
}

function icoGitBranch(ctx,cx,cy,col) {
  ctx.save(); ctx.strokeStyle=col; ctx.lineWidth=1.8; ctx.shadowColor=col; ctx.shadowBlur=10;
  ctx.beginPath(); ctx.moveTo(cx-6,cy+11); ctx.lineTo(cx-6,cy-5); ctx.stroke();
  ctx.beginPath(); ctx.moveTo(cx-6,cy-3); ctx.quadraticCurveTo(cx-6,cy-11,cx+6,cy-11); ctx.stroke();
  [[-6,12],[-6,-8],[6,-11]].forEach(([dx,dy])=>{
    ctx.fillStyle=col; ctx.shadowBlur=14;
    ctx.beginPath(); ctx.arc(cx+dx,cy+dy,3,0,Math.PI*2); ctx.fill();
  });
  ctx.restore();
}

function icoLightning(ctx,cx,cy,col) {
  ctx.save(); ctx.fillStyle=col; ctx.shadowColor=col; ctx.shadowBlur=16;
  ctx.beginPath();
  ctx.moveTo(cx+4,cy-13); ctx.lineTo(cx-4,cy); ctx.lineTo(cx+2,cy); ctx.lineTo(cx-4,cy+13);
  ctx.lineTo(cx+4,cy); ctx.lineTo(cx-2,cy); ctx.closePath(); ctx.fill();
  ctx.restore();
}

function icoTerminal(ctx,cx,cy,col) {
  ctx.save(); ctx.strokeStyle=col; ctx.lineWidth=1.5; ctx.shadowColor=col; ctx.shadowBlur=8;
  ctx.strokeRect(cx-13,cy-10,26,20);
  // Prompt chevron
  ctx.fillStyle=col; ctx.shadowBlur=12;
  ctx.font='700 11px "JetBrains Mono"'; ctx.textAlign='left'; ctx.textBaseline='middle';
  ctx.fillText('$_', cx-9, cy);
  ctx.restore();
}

function icoGrid4(ctx,cx,cy,col) {
  ctx.save(); ctx.shadowColor=col; ctx.shadowBlur=10;
  const s=7, g=3;
  [[-1,-1],[-1,1],[1,-1],[1,1]].forEach(([dx,dy])=>{
    ctx.fillStyle=rgba(col, dx*dy>0?1:0.6);
    ctx.fillRect(cx+dx*(s+g)/2-s/2, cy+dy*(s+g)/2-s/2, s, s);
  });
  ctx.restore();
}

function icoPlusMinus(ctx,cx,cy,col) {
  ctx.save(); ctx.strokeStyle=col; ctx.lineWidth=1.8; ctx.shadowColor=col; ctx.shadowBlur=10;
  ctx.strokeRect(cx-12,cy-12,24,24);
  ctx.lineWidth=1.5;
  ctx.beginPath(); ctx.moveTo(cx,cy-6); ctx.lineTo(cx,cy+6); ctx.stroke();
  ctx.beginPath(); ctx.moveTo(cx-6,cy); ctx.lineTo(cx+6,cy); ctx.stroke();
  ctx.restore();
}

function icoCircuit(ctx,cx,cy,col) {
  ctx.save(); ctx.lineWidth=1.2; ctx.shadowColor=col; ctx.shadowBlur=8;
  const nodes=[[cx,cy],[cx-11,cy-7],[cx+11,cy-7],[cx-11,cy+7],[cx+11,cy+7]];
  ctx.strokeStyle=rgba(col,0.5);
  [[0,1],[0,2],[0,3],[0,4],[1,2],[3,4]].forEach(([a,b])=>{
    ctx.beginPath(); ctx.moveTo(nodes[a][0],nodes[a][1]); ctx.lineTo(nodes[b][0],nodes[b][1]); ctx.stroke();
  });
  nodes.forEach(([x,y],i)=>{
    ctx.fillStyle=i===0?col:rgba(col,0.7); ctx.shadowBlur=i===0?14:6;
    ctx.beginPath(); ctx.arc(x,y,i===0?4:2.5,0,Math.PI*2); ctx.fill();
  });
  ctx.restore();
}

function icoQuestion(ctx,cx,cy,col) {
  ctx.save(); ctx.strokeStyle=col; ctx.lineWidth=1.5; ctx.shadowColor=col; ctx.shadowBlur=10;
  ctx.beginPath(); ctx.arc(cx,cy,13,0,Math.PI*2); ctx.stroke();
  ctx.fillStyle=col; ctx.shadowBlur=12;
  ctx.font='800 15px "JetBrains Mono"'; ctx.textAlign='center'; ctx.textBaseline='middle';
  ctx.fillText('?', cx, cy+1);
  ctx.restore();
}

function icoStack(ctx,cx,cy,col) {
  ctx.save(); ctx.strokeStyle=col; ctx.lineWidth=1.2; ctx.shadowColor=col; ctx.shadowBlur=8;
  for(let i=0;i<4;i++){
    const y=cy-9+i*6, w=20-i*3;
    ctx.strokeRect(cx-w/2, y-2.5, w, 5);
  }
  ctx.restore();
}

function icoChart(ctx,cx,cy,col) {
  ctx.save();
  const bars=[[0,14],[10,22],[20,9],[30,18],[40,26]];
  bars.forEach(([dx,h])=>{
    ctx.fillStyle=rgba(col, 0.55+h/50);
    ctx.shadowColor=col; ctx.shadowBlur=6;
    ctx.fillRect(cx-20+dx, cy+10-h, 7, h);
  });
  ctx.strokeStyle=rgba(col,0.7); ctx.lineWidth=1; ctx.shadowBlur=0;
  ctx.beginPath(); ctx.moveTo(cx-22,cy-14); ctx.lineTo(cx-22,cy+11); ctx.lineTo(cx+24,cy+11); ctx.stroke();
  ctx.restore();
}

// ══ SECTION DEFINITIONS ═══════════════════════════════════

const SECTIONS = [
  { id:'s-00', num:'//',    title:'WHAT IS THIS',                  color:C.cyan,     icon:icoComment  },
  { id:'s-01', num:'[00]',  title:'PAYLOAD MANIFEST',              color:C.rose,     icon:icoDoc      },
  { id:'s-02', num:'[01]',  title:'SYSTEM REQUIREMENTS',           color:C.iris,     icon:icoChecks   },
  { id:'s-03', num:'[02]',  title:'PRE-FLIGHT',                    color:C.amber,    icon:icoCrosshair},
  { id:'s-04', num:'[03]',  title:'INSTALLATION',                  color:C.phosphor, icon:icoDownArrow},
  { id:'s-05', num:'[04]',  title:'DEPLOY FROM GITHUB',            color:C.cyan,     icon:icoGitBranch},
  { id:'s-06', num:'[05]',  title:'WHEN THINGS BREAK',             color:C.amber,    icon:icoLightning},
  { id:'s-07', num:'[06]',  title:'DAILY OPS',                     color:C.phosphor, icon:icoTerminal },
  { id:'s-08', num:'[07]',  title:'ARSENAL — CATEGORIES & PRESETS',color:C.rose,     icon:icoGrid4    },
  { id:'s-09', num:'[08]',  title:'ADDING & REMOVING PACKAGES',    color:C.iris,     icon:icoPlusMinus},
  { id:'s-10', num:'[09]',  title:'ARCHITECTURE',                  color:C.cyan,     icon:icoCircuit  },
  { id:'s-11', num:'[10]',  title:'TROUBLESHOOTING',               color:C.amber,    icon:icoQuestion },
  { id:'s-12', num:'[11]',  title:'DOCUMENTATION',                 color:C.iris,     icon:icoStack    },
  { id:'s-13', num:'[12]',  title:'BENCHMARKING — NIXOS vs KALI',  color:C.phosphor, icon:icoChart    },
];

// ══ DRAW FUNCTION ═════════════════════════════════════════

function drawSectionHeader(canvas, sec) {
  const W=HDR_W, H=HDR_H;
  canvas.width=W; canvas.height=H;
  const ctx=canvas.getContext('2d');

  // Base
  fillBg(ctx,W,H);
  drawHexGridTight(ctx,W,H);
  drawScanlines(ctx,W,H);

  // Left icon area wash
  const wash=ctx.createLinearGradient(0,0,110,0);
  wash.addColorStop(0, rgba(sec.color,0.1));
  wash.addColorStop(1, 'rgba(0,0,0,0)');
  ctx.fillStyle=wash; ctx.fillRect(0,0,110,H);

  // Right side fade
  const rfade=ctx.createLinearGradient(W-120,0,W,0);
  rfade.addColorStop(0,'rgba(0,0,0,0)');
  rfade.addColorStop(1, rgba(sec.color,0.04));
  ctx.fillStyle=rfade; ctx.fillRect(W-120,0,120,H);

  // Icon
  sec.icon(ctx, 40, H/2, sec.color);

  // Vertical divider
  ctx.save();
  const dg=ctx.createLinearGradient(0,6,0,H-6);
  dg.addColorStop(0,'rgba(0,0,0,0)');
  dg.addColorStop(.3,rgba(sec.color,0.4));
  dg.addColorStop(.7,rgba(sec.color,0.4));
  dg.addColorStop(1,'rgba(0,0,0,0)');
  ctx.strokeStyle=dg; ctx.lineWidth=1;
  ctx.beginPath(); ctx.moveTo(78,6); ctx.lineTo(78,H-6); ctx.stroke();
  ctx.restore();

  // Section number
  label(ctx, sec.num, 92, H/2-12, {color:sec.color, size:10, weight:600, align:'left', alpha:0.75});

  // Section title — main text
  glowText(ctx, sec.title, 92, H/2+11, {
    color:sec.color, size:20, weight:700,
    align:'left', baseline:'middle',
    outerGlow:18, innerGlow:5,
  });

  // Right Nix snowflake watermark
  drawNixFlake(ctx, W-38, H/2, 20, sec.color, 0.12);

  // Bottom accent line (gradient)
  ctx.save();
  const bg=ctx.createLinearGradient(0,0,W,0);
  bg.addColorStop(0,'rgba(0,0,0,0)');
  bg.addColorStop(.06, rgba(sec.color,0.7));
  bg.addColorStop(.94, rgba(sec.color,0.7));
  bg.addColorStop(1,'rgba(0,0,0,0)');
  ctx.strokeStyle=bg; ctx.lineWidth=1.5;
  ctx.shadowColor=sec.color; ctx.shadowBlur=6;
  ctx.beginPath(); ctx.moveTo(0,H-1); ctx.lineTo(W,H-1); ctx.stroke();
  ctx.restore();

  // Top micro-rule (very subtle)
  ctx.save();
  ctx.strokeStyle=rgba(sec.color,0.12); ctx.lineWidth=1;
  ctx.beginPath(); ctx.moveTo(0,0); ctx.lineTo(W,0); ctx.stroke();
  ctx.restore();
}

// ══ INIT ══════════════════════════════════════════════════

function initHeaders() {
  SECTIONS.forEach(sec=>{
    const canvas=document.getElementById(sec.id);
    if(canvas) drawSectionHeader(canvas, sec);
  });
}

function dlHeader(secId) {
  const sec=SECTIONS.find(s=>s.id===secId);
  if(!sec) return;
  const off=document.createElement('canvas');
  drawSectionHeader(off, sec);
  const name=sec.title.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'');
  const a=document.createElement('a');
  a.download=`icebreaker-header-${name}.png`;
  a.href=off.toDataURL('image/png'); a.click();
}

async function dlAllHeaders() {
  const zip = new JSZip();
  const folder = zip.folder('section-headers');
  SECTIONS.forEach((sec,i)=>{
    const off=document.createElement('canvas');
    drawSectionHeader(off,sec);
    const name=sec.title.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'');
    const fname=`${String(i).padStart(2,'0')}-${name}.png`;
    folder.file(fname, off.toDataURL('image/png').split(',')[1], {base64:true});
  });
  const blob=await zip.generateAsync({type:'blob'});
  const a=document.createElement('a');
  a.download='icebreaker-section-headers.zip';
  a.href=URL.createObjectURL(blob); a.click();
}

Object.assign(window, { SECTIONS, initHeaders, dlHeader, dlAllHeaders });
