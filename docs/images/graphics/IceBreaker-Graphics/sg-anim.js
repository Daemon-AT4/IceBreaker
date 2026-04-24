'use strict';
// ── sg-anim.js ── Animated canvas previews + GIF export ────

// ══ MATRIX RAIN ═══════════════════════════════════════════
class MatrixRain {
  constructor(W, H, seed) {
    this.W=W; this.H=H;
    this.rand=makePRNG(seed);
    const cols=Math.floor(W/11);
    this.glyphs='01アイウエカキクケコ∂∆∇∫≡≈[]{}|~^';
    this.drops=Array.from({length:cols},(_,i)=>({
      x: i*11 + this.rand()*4,
      y: this.rand()*H,
      speed: 0.4+this.rand()*1.2,
      bright: 0.3+this.rand()*0.7,
      char: this.glyphs[Math.floor(this.rand()*this.glyphs.length)],
      ttl: Math.floor(this.rand()*60),
    }));
  }
  update() {
    this.drops.forEach(d=>{
      d.y += d.speed;
      d.ttl--;
      if(d.ttl<=0){ d.char=this.glyphs[Math.floor(Math.random()*this.glyphs.length)]; d.ttl=Math.floor(Math.random()*60)+10; }
      if(d.y>this.H+20){ d.y=-20; d.speed=0.4+Math.random()*1.2; d.bright=0.3+Math.random()*0.7; }
    });
  }
  draw(ctx) {
    ctx.save();
    ctx.font='11px "JetBrains Mono"';
    ctx.textBaseline='top';
    this.drops.forEach(d=>{
      const a=d.bright*0.06;
      // Faint trail
      ctx.fillStyle=rgba(C.phosphor,a);
      ctx.fillText(d.char,d.x,d.y);
      // Bright head flash
      if(d.bright>0.7){
        ctx.fillStyle=rgba(C.phosphor,a*4);
        ctx.fillText(d.char,d.x,d.y+11);
      }
    });
    ctx.restore();
  }
}

// ══ ANIMATED SOCIAL PREVIEW 1280×640 ══════════════════════
const SOCIAL_W=1280, SOCIAL_H=640;
const rainSocial=new MatrixRain(SOCIAL_W,SOCIAL_H,7);

// Pre-render static bg layer once
let socialBg=null;
function buildSocialBg() {
  const c=document.createElement('canvas');
  c.width=SOCIAL_W; c.height=SOCIAL_H;
  const ctx=c.getContext('2d');
  fillBg(ctx,SOCIAL_W,SOCIAL_H);
  drawHexGrid(ctx,SOCIAL_W,SOCIAL_H);
  drawCircuits(ctx,SOCIAL_W,SOCIAL_H,22,makePRNG(7));
  drawVignette(ctx,SOCIAL_W,SOCIAL_H,0.72);
  drawScanlines(ctx,SOCIAL_W,SOCIAL_H);
  drawBrackets(ctx,SOCIAL_W,SOCIAL_H,38,58,C.rose,0.8);
  return c;
}

function drawAnimSocial(canvas, t) {
  if(!socialBg) socialBg=buildSocialBg();
  const W=SOCIAL_W, H=SOCIAL_H;
  const ctx=canvas.getContext('2d');
  canvas.width=W; canvas.height=H;

  // Composite static bg
  ctx.drawImage(socialBg,0,0);

  // Matrix rain (updated externally)
  rainSocial.draw(ctx);

  // Breathing centre glow
  const breathe=0.07+0.03*Math.sin(t*0.0014);
  drawCenterGlow(ctx,W,H,H/2-20,C.iris,380,breathe);

  // Scanline sweep
  const sweep=(t*0.055)%H;
  const sg=ctx.createLinearGradient(0,sweep-35,0,sweep+35);
  sg.addColorStop(0,'rgba(255,255,255,0)');
  sg.addColorStop(0.5,'rgba(200,255,240,0.025)');
  sg.addColorStop(1,'rgba(255,255,255,0)');
  ctx.fillStyle=sg; ctx.fillRect(0,sweep-35,W,70);

  // Top-left eyebrow
  label(ctx,'DΛΣMӨП // PRESENTS :',72,70,{color:C.amber,size:12,weight:600,align:'left',glow:true});
  label(ctx,'NEUROMANCER-GRADE NIXOS',W-72,62,{color:rgba(C.subtle,0.55),size:10,align:'right'});
  label(ctx,'PENTEST ENVIRONMENT',W-72,78,{color:rgba(C.subtle,0.55),size:10,align:'right'});

  // Nix flake watermark (slowly spinning)
  drawNixFlake(ctx,W-105,H-105,68,C.iris,0.1);

  // Glitch offset: occasional random chromatic shift
  const glitch=Math.sin(t*0.003)*Math.sin(t*0.007);
  const chrShift=glitch>0.85?4:0;

  // ICEBREAKER — pulsing glow
  const outerG=50+18*Math.sin(t*0.0018);
  glowText(ctx,'ICEBREAKER',W/2,H/2-30,{
    color:C.phosphor,size:134,weight:800,
    outerGlow:outerG,innerGlow:14,chromatic:true,
    ...(chrShift?{color:C.pale}:{}),
  });

  // Divider + diamond
  ctx.save();
  ctx.strokeStyle=rgba(C.rose,0.5); ctx.lineWidth=1;
  ctx.shadowColor=C.rose; ctx.shadowBlur=6;
  ctx.beginPath(); ctx.moveTo(W/2-240,H/2+55); ctx.lineTo(W/2+240,H/2+55); ctx.stroke();
  ctx.translate(W/2,H/2+55); ctx.rotate(Math.PI/4+t*0.0004);
  ctx.fillStyle=C.rose; ctx.shadowBlur=10; ctx.fillRect(-4,-4,8,8);
  ctx.restore();

  // Subtitle
  glowText(ctx,'// NEUROMANCER-GRADE NIXOS PENTEST FLAKE',W/2,H/2+90,{
    color:C.cyan,size:18,weight:500,outerGlow:22,innerGlow:6,
  });

  // Stat pills
  statPills(ctx,W,H/2+135,[
    {val:'12',sub:'CATEGORIES'},
    {val:'54%',sub:'FASTER DEPLOY'},
    {val:'82.5',sub:'SUS EXCELLENT'},
    {val:'50+',sub:'ALIASES'},
  ]);

  // Status bar with blinking cursor
  const blink=Math.floor(t/500)%2===0;
  statusBar(ctx,W,H,`${blink?'▌':'  '}  ALL SYSTEMS OPERATIONAL   ·   jacking in...`);
}

// ══ ANIMATED BANNER 1200×340 ══════════════════════════════
const BAN_W=1200, BAN_H=340;
const rainBanner=new MatrixRain(BAN_W,BAN_H,13);

let bannerBg=null;
function buildBannerBg() {
  const c=document.createElement('canvas');
  c.width=BAN_W; c.height=BAN_H;
  const ctx=c.getContext('2d');
  const bg=ctx.createLinearGradient(0,0,BAN_W,0);
  bg.addColorStop(0,'#0e0c18'); bg.addColorStop(.5,'#0a0e14'); bg.addColorStop(1,'#0e0c18');
  ctx.fillStyle=bg; ctx.fillRect(0,0,BAN_W,BAN_H);
  drawHexGrid(ctx,BAN_W,BAN_H);
  drawCircuits(ctx,BAN_W,BAN_H,14,makePRNG(13));
  drawVignette(ctx,BAN_W,BAN_H,0.52);
  drawScanlines(ctx,BAN_W,BAN_H);
  drawBrackets(ctx,BAN_W,BAN_H,24,42,C.rose,0.75);
  // Dashed dividers
  ctx.setLineDash([4,8]); ctx.strokeStyle=rgba(C.iris,0.12); ctx.lineWidth=1;
  [[190,30,190,BAN_H-30],[BAN_W-190,30,BAN_W-190,BAN_H-30]].forEach(([x1,y1,x2,y2])=>{
    ctx.beginPath();ctx.moveTo(x1,y1);ctx.lineTo(x2,y2);ctx.stroke();
  });
  return c;
}

// Floating particles for banner
const particles=Array.from({length:40},()=>({
  x:Math.random()*BAN_W, y:Math.random()*BAN_H,
  vx:(Math.random()-0.5)*0.18, vy:(Math.random()-0.5)*0.18,
  r:Math.random()*2+0.5, alpha:Math.random()*0.3+0.05,
  col:[C.iris,C.cyan,C.phosphor,C.rose][Math.floor(Math.random()*4)],
}));

function drawAnimBanner(canvas, t) {
  if(!bannerBg) bannerBg=buildBannerBg();
  const W=BAN_W, H=BAN_H;
  const ctx=canvas.getContext('2d');
  canvas.width=W; canvas.height=H;

  ctx.drawImage(bannerBg,0,0);
  rainBanner.draw(ctx);

  // Breathe glow
  const breathe=0.06+0.025*Math.sin(t*0.0016);
  drawCenterGlow(ctx,W,H,H/2,C.iris,280,breathe);

  // Scanline sweep
  const sweep=(t*0.04)%H;
  const sg=ctx.createLinearGradient(0,sweep-25,0,sweep+25);
  sg.addColorStop(0,'rgba(255,255,255,0)');
  sg.addColorStop(0.5,'rgba(200,255,240,0.02)');
  sg.addColorStop(1,'rgba(255,255,255,0)');
  ctx.fillStyle=sg; ctx.fillRect(0,sweep-25,W,50);

  // Floating particles
  particles.forEach(p=>{
    p.x+=p.vx; p.y+=p.vy;
    if(p.x<0)p.x=W; if(p.x>W)p.x=0;
    if(p.y<0)p.y=H; if(p.y>H)p.y=0;
    ctx.save();
    ctx.fillStyle=rgba(p.col,p.alpha);
    ctx.shadowColor=p.col; ctx.shadowBlur=6;
    ctx.beginPath(); ctx.arc(p.x,p.y,p.r,0,Math.PI*2); ctx.fill();
    ctx.restore();
  });

  // Nix flakes (slowly rotating)
  drawNixFlake(ctx,80,H/2,48,C.iris,0.22+0.08*Math.sin(t*0.001));
  drawNixFlake(ctx,W-80,H/2,48,C.iris,0.22+0.08*Math.sin(t*0.001+1));

  // DΛΣMӨП + subtitle
  label(ctx,'D Λ Σ M Ө П',W/2,H/2-82,{color:C.amber,size:13,weight:600,glow:true});
  label(ctx,'presents ::',W/2,H/2-64,{color:rgba(C.subtle,0.45),size:10});

  // ICEBREAKER
  const outerG=42+16*Math.sin(t*0.0018);
  glowText(ctx,'ICEBREAKER',W/2,H/2-12,{
    color:C.phosphor,size:92,weight:800,outerGlow:outerG,innerGlow:12,chromatic:true,
  });

  // Bottom rule + tagline
  ctx.save();
  const rg=ctx.createLinearGradient(0,0,W,0);
  rg.addColorStop(0,'rgba(0,0,0,0)'); rg.addColorStop(.25,rgba(C.rose,0.35));
  rg.addColorStop(.5,rgba(C.rose,0.6)); rg.addColorStop(.75,rgba(C.rose,0.35)); rg.addColorStop(1,'rgba(0,0,0,0)');
  ctx.strokeStyle=rg; ctx.lineWidth=1; ctx.shadowColor=C.rose; ctx.shadowBlur=8;
  ctx.beginPath(); ctx.moveTo(0,H-52); ctx.lineTo(W,H-52); ctx.stroke();
  ctx.restore();

  glowText(ctx,'NixOS Pentesting Environment  //  Modular Flake  //  Rose Pine',W/2,H/2+58,{
    color:C.cyan,size:13,weight:400,outerGlow:16,innerGlow:4,
  });

  const tags=['x86_64-linux','aarch64-linux','Rose Pine Dark','JetBrains Mono','Neuromancer'];
  const tw=W/tags.length;
  tags.forEach((t2,i)=>label(ctx,t2,tw*i+tw/2,H-28,{color:rgba(C.subtle,0.38),size:9}));
}

// ══ ANIMATION LOOP ════════════════════════════════════════
let animRunning=false;
let lastRainUpdate=0;

function startAnim() {
  if(animRunning) return;
  animRunning=true;
  const cSocial=document.getElementById('ca-social');
  const cBanner=document.getElementById('ca-banner');

  function loop(ts) {
    if(!animRunning) return;
    if(ts-lastRainUpdate>40){ // ~25fps rain update
      rainSocial.update();
      rainBanner.update();
      lastRainUpdate=ts;
    }
    drawAnimSocial(cSocial, ts);
    drawAnimBanner(cBanner, ts);
    recordFrame(cSocial, cBanner, ts);
    requestAnimationFrame(loop);
  }
  requestAnimationFrame(loop);
}

// ══ GIF EXPORT ════════════════════════════════════════════
const GIF_FPS=12, GIF_DURATION=3; // 3 seconds
const GIF_FRAMES=GIF_FPS*GIF_DURATION;
let recording={social:false,banner:false};
let gifFrames={social:[],banner:[]};
let gifStartTime={social:0,banner:0};

function startRecording(which) {
  if(recording[which]) return;
  recording[which]=true;
  gifFrames[which]=[];
  gifStartTime[which]=performance.now();
  const btn=document.getElementById(`rec-${which}`);
  if(btn){ btn.textContent=`⏺ Recording... 0/${GIF_FRAMES}`; btn.disabled=true; }
}

function recordFrame(cSocial, cBanner, ts) {
  ['social','banner'].forEach(which=>{
    if(!recording[which]) return;
    const elapsed=ts-gifStartTime[which];
    const frameTarget=Math.floor(elapsed/(1000/GIF_FPS));
    if(gifFrames[which].length<frameTarget && gifFrames[which].length<GIF_FRAMES) {
      const src=which==='social'?cSocial:cBanner;
      const snap=document.createElement('canvas');
      snap.width=src.width; snap.height=src.height;
      snap.getContext('2d').drawImage(src,0,0);
      gifFrames[which].push(snap);
      const btn=document.getElementById(`rec-${which}`);
      if(btn) btn.textContent=`⏺ Recording... ${gifFrames[which].length}/${GIF_FRAMES}`;
    }
    if(gifFrames[which].length>=GIF_FRAMES) {
      recording[which]=false;
      encodeGif(which);
    }
  });
}

function encodeGif(which) {
  const btn=document.getElementById(`rec-${which}`);
  if(btn){ btn.textContent='⚙ Encoding GIF…'; }
  try {
    const frames=gifFrames[which];
    const W=frames[0].width, H=frames[0].height;
    const gif=new GIF({
      workers:2, quality:8, repeat:0,
      workerScript:'https://unpkg.com/gif.js@0.2.0/dist/gif.worker.js',
      width:W, height:H,
    });
    frames.forEach(f=>gif.addFrame(f,{copy:true,delay:Math.round(1000/GIF_FPS)}));
    gif.on('finished',blob=>{
      const a=document.createElement('a');
      a.download=`icebreaker-${which}-animated.gif`;
      a.href=URL.createObjectURL(blob); a.click();
      if(btn){ btn.textContent=`⏺ Record GIF — 3s`; btn.disabled=false; }
    });
    gif.on('error',e=>{
      console.error('GIF error',e);
      if(btn){ btn.textContent='⏺ Record GIF — 3s'; btn.disabled=false; }
    });
    gif.render();
  } catch(e) {
    console.error(e);
    if(btn){ btn.textContent='⏺ Record GIF — 3s (gif.js failed — try screen record)'; btn.disabled=false; }
  }
}

// ══ INIT ══════════════════════════════════════════════════
function initAnim() {
  const cSocial=document.getElementById('ca-social');
  const cBanner=document.getElementById('ca-banner');
  if(cSocial){ cSocial.width=SOCIAL_W; cSocial.height=SOCIAL_H; }
  if(cBanner){ cBanner.width=BAN_W; cBanner.height=BAN_H; }
  startAnim();
  document.getElementById('rec-social')?.addEventListener('click',()=>startRecording('social'));
  document.getElementById('rec-banner')?.addEventListener('click',()=>startRecording('banner'));
}

Object.assign(window, { initAnim });
