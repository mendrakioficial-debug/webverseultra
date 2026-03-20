const DB={users:'wv_users_max',session:'wv_session_max',generalChats:'wv_general_chats_max',privateChats:'wv_private_chats_max',official:'wv_official_posts_max',theme:'wv_theme_max',ads:'wv_ads_max',ownerUnlocked:'wv_owner_unlocked_max',settings:'wv_audio_settings_max'};
const OWNER_EMAIL='mendraki0801@gmail.com', OWNER_PIN='666777';
const defaultOfficials=[
  {title:'WebVerse Ultra MAX lançado',text:'Nova versão com Snake, loja, ranking, missões, música e muito mais.',date:'Hoje'},
  {title:'Arcade expandido',text:'Agora você pode escolher jogos diferentes e ganhar moedas por jogar.',date:'Hoje'},
  {title:'Loja Cósmica ativada',text:'Itens desbloqueáveis agora podem ser comprados com moedas do próprio site.',date:'Hoje'}
];
const generalRooms=[
  {id:'geral-1',title:'# geral-1',desc:'Conversa aberta para todos os logados.'},
  {id:'geral-2',title:'# geral-2',desc:'Mais uma sala geral para a comunidade.'},
  {id:'geral-3',title:'# geral-3',desc:'Sala geral extra do WebVerse.'}
];
const siteWallpapers=[
  'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1200&q=80',
  'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=1200&q=80',
  'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80',
  'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?auto=format&fit=crop&w=1200&q=80',
  'https://images.unsplash.com/photo-1520034475321-cbe63696469a?auto=format&fit=crop&w=1200&q=80',
  'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=1200&q=80'
];
const accentColors=['#5df2ff','#46b3ff','#8c6dff','#ff62c7','#00ff99','#ffd700','#ff4d6d','#00ffff','#32cd32','#ff7f50','#ffffff','#ff00ea'];
const profileEffects=[
  {id:'none',name:'Sem efeito'},
  {id:'glow',name:'Glow'},
  {id:'rainbow',name:'Arco-íris'},
  {id:'pulse',name:'Pulse'},
  {id:'shadow',name:'Shadow'}
];
const shopItems=[
  {id:'title_arcade',name:'Título: Rei do Arcade',type:'title',value:'👑 Rei do Arcade',price:120,desc:'Mostra um título lendário no perfil.'},
  {id:'title_neon',name:'Título: Mestre Neon',type:'title',value:'✨ Mestre Neon',price:160,desc:'Título brilhante para perfil.'},
  {id:'frame_gold',name:'Moldura Dourada',type:'frame',value:'linear-gradient(135deg,#ffd700,#ff9f1c,#fff1a8)',price:220,desc:'Moldura premium para o avatar.'},
  {id:'frame_ice',name:'Moldura Ice',type:'frame',value:'linear-gradient(135deg,#5df2ff,#46b3ff,#ffffff)',price:180,desc:'Moldura gelada brilhante.'},
  {id:'effect_shadowplus',name:'Efeito Shadow Plus',type:'profileEffectUnlock',value:'shadow',price:130,desc:'Desbloqueia efeito shadow no perfil.'},
  {id:'theme_cosmic',name:'Tema Cósmico',type:'wallpaper',value:'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?auto=format&fit=crop&w=1200&q=80',price:260,desc:'Plano de fundo espacial premium.'},
  {id:'theme_gamer',name:'Tema Gamer',type:'wallpaper',value:'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=1200&q=80',price:260,desc:'Fundo gamer premium.'},
  {id:'coin_pack_small',name:'Pacote de Sorte',type:'reward',value:70,price:90,desc:'Compra 70 moedas por diversão de teste.'}
];
const missionTemplates=[
  {id:'play_3',title:'Jogue 3 partidas',desc:'Complete 3 partidas em qualquer jogo.',rewardCoins:40,rewardXp:40,target:3,key:'gamesPlayed'},
  {id:'win_2',title:'Vença 2 vezes',desc:'Consiga 2 vitórias.',rewardCoins:60,rewardXp:60,target:2,key:'wins'},
  {id:'snake_8',title:'Snake 8+',desc:'Faça pelo menos 8 pontos no Snake.',rewardCoins:80,rewardXp:80,target:8,key:'snakeBest'}
];

let currentGeneralRoom='geral-1', currentPrivateFriendId=null, currentChatMode='general';
const $=id=>document.getElementById(id);
const getJSON=(k,f)=>{try{return JSON.parse(localStorage.getItem(k))??f}catch{return f}};
const setJSON=(k,v)=>localStorage.setItem(k,JSON.stringify(v));

function toast(text){
  const el=$('toast');
  if(!el){ alert(text); return; }
  el.textContent=text;
  el.classList.add('show');
  clearTimeout(window.toastTimer);
  window.toastTimer=setTimeout(()=>el.classList.remove('show'),2600);
}
const uid=()=>Math.random().toString(36).slice(2,10);
const normalize=s=>(s||'').trim().replace(/\s+/g,' ').toLowerCase();
const gmailOk=g=>/^[a-zA-Z0-9._%+-]+@gmail\.com$/.test((g||'').trim());
const nowTime=()=>new Date().toLocaleTimeString('pt-BR',{hour:'2-digit',minute:'2-digit'});
const currentUser=()=>getJSON(DB.session,null);
const isOwner=(u=currentUser())=>!!u && normalize(u.email)===normalize(OWNER_EMAIL);
const isOwnerUnlocked=()=>!!localStorage.getItem(DB.ownerUnlocked);
const escapeHtml=(s='')=>s.replace(/[&<>"']/g,m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#039;'}[m]));
const getDefaultStats=()=>({xp:0,level:1,coins:0,wins:0,gamesPlayed:0,snakeBest:0,tttWins:0,memoryWins:0,quizWins:0,reactionBest:0,rpsWins:0,inventory:[],title:'',frame:'',missionsClaimed:[],achievements:[]});

function userWithDefaults(user){
  if(!user) return null;
  user.stats={...getDefaultStats(),...(user.stats||{})};
  user.friends=user.friends||[];
  user.bio=user.bio||'';
  user.profileEffect=user.profileEffect||'none';
  user.avatar=user.avatar||makeAvatarData(1);
  user.muted=!!user.muted;
  user.banned=!!user.banned;
  user.lastDaily=user.lastDaily||'';
  return user;
}

const xpNeeded=l=>100+(l-1)*50;

function persistCurrentUser(user){
  user=userWithDefaults(user);
  const users=getJSON(DB.users,[]).map(userWithDefaults);
  const i=users.findIndex(u=>u.id===user.id);
  if(i>=0) users[i]=user;
  setJSON(DB.users,users);
  setJSON(DB.session,user);
}

function addXp(amount){
  const user=userWithDefaults(currentUser());
  if(!user) return;
  user.stats.xp+=amount;
  let leveledUp=false;
  while(user.stats.xp>=xpNeeded(user.stats.level)){
    user.stats.xp-=xpNeeded(user.stats.level);
    user.stats.level++;
    user.stats.coins+=50;
    leveledUp=true;
  }
  persistCurrentUser(user);
  if(leveledUp){
    playSfx('levelup');
    toast('Você subiu de nível e ganhou 50 moedas!');
    unlockAchievement('Primeiro nível alto',user.stats.level>=5);
  }
  updateUserUI();
}

function addCoins(amount){
  const user=userWithDefaults(currentUser());
  if(!user) return;
  user.stats.coins+=amount;
  persistCurrentUser(user);
  playSfx('coin');
  updateUserUI();
}

function spendCoins(amount){
  const user=userWithDefaults(currentUser());
  if(!user) return false;
  if(user.stats.coins<amount) return false;
  user.stats.coins-=amount;
  persistCurrentUser(user);
  updateUserUI();
  return true;
}

function recordGamePlayed(){
  const user=userWithDefaults(currentUser());
  if(!user) return;
  user.stats.gamesPlayed++;
  persistCurrentUser(user);
  addXp(10);
  refreshMissionsAndAchievements();
}

function recordWin(type){
  const user=userWithDefaults(currentUser());
  if(!user) return;
  user.stats.wins++;
  if(type==='ttt') user.stats.tttWins++;
  if(type==='memory') user.stats.memoryWins++;
  if(type==='quiz') user.stats.quizWins++;
  if(type==='rps') user.stats.rpsWins++;
  persistCurrentUser(user);
  addXp(30);
  addCoins(20);
  refreshMissionsAndAchievements();
}

function setReactionBest(ms){
  const user=userWithDefaults(currentUser());
  if(!user) return;
  if(user.stats.reactionBest===0||ms<user.stats.reactionBest){
    user.stats.reactionBest=ms;
    persistCurrentUser(user);
    addXp(15);
    addCoins(15);
    refreshMissionsAndAchievements();
  }
}

function setSnakeBest(score){
  const user=userWithDefaults(currentUser());
  if(!user) return;
  if(score>user.stats.snakeBest){
    user.stats.snakeBest=score;
    persistCurrentUser(user);
    addXp(20+score*2);
    addCoins(15+score*3);
    refreshMissionsAndAchievements();
  }
}

function claimDailyReward(){
  const user=userWithDefaults(currentUser());
  if(!user) return toast('Faça login para pegar a recompensa diária.');
  const today=new Date().toLocaleDateString('pt-BR');
  if(user.lastDaily===today) return toast('Você já pegou a recompensa diária de hoje.');
  user.lastDaily=today;
  user.stats.coins+=100;
  user.stats.xp+=35;
  persistCurrentUser(user);
  addXp(0);
  playSfx('reward');
  toast('Recompensa diária recebida: 100 moedas e 35 XP!');
  refreshMissionsAndAchievements();
}

const hasItem=(user,id)=>{
  user=userWithDefaults(user);
  return user.stats.inventory.includes(id);
};

function buyItem(itemId){
  const user=userWithDefaults(currentUser());
  if(!user) return toast('Faça login para comprar.');
  const item=shopItems.find(i=>i.id===itemId);
  if(!item) return;
  if(hasItem(user,itemId)) return toast('Você já possui esse item.');
  if(!spendCoins(item.price)) return toast('Moedas insuficientes.');
  const updated=userWithDefaults(currentUser());
  updated.stats.inventory.push(itemId);
  if(item.type==='title') updated.stats.title=item.value;
  if(item.type==='frame') updated.stats.frame=item.value;
  if(item.type==='reward') updated.stats.coins+=item.value;
  persistCurrentUser(updated);
  playSfx('buy');
  toast('Compra realizada com sucesso!');
  renderShop();
  updateUserUI();
}

function initParticles(){
  const area=$('particles');
  if(!area) return;
  for(let i=0;i<32;i++){
    const p=document.createElement('div');
    p.className='particle';
    p.style.left=Math.random()*100+'vw';
    p.style.animationDuration=(8+Math.random()*12)+'s';
    p.style.animationDelay=(Math.random()*10)+'s';
    p.style.width=(3+Math.random()*5)+'px';
    p.style.height=p.style.width;
    area.appendChild(p);
  }
}

function openSection(id){
  document.querySelectorAll('.section').forEach(s=>s.classList.remove('active'));
  document.querySelectorAll('.nav-btn').forEach(b=>b.classList.remove('active'));
  const sec=$(id);
  if(sec) sec.classList.add('active');
  const navBtn=document.querySelector(`.nav-btn[data-section="${id}"]`);
  if(navBtn) navBtn.classList.add('active');
  window.scrollTo({top:0,behavior:'smooth'});
  if(id==='hub') renderHub();
  if(id==='admin') renderAdminPanel();
  if(id==='rank') renderRanking();
  if(id==='shop') renderShop();
  if(id==='missions') renderMissions();
  playSfx('click');
}

document.querySelectorAll('.nav-btn').forEach(btn=>btn.addEventListener('click',()=>openSection(btn.dataset.section)));

function openAuth(tab='login'){
  const modal=$('authModal');
  if(!modal) return;
  modal.classList.add('show');
  setAuthTab(tab);
}
function closeAuth(){
  const modal=$('authModal');
  if(modal) modal.classList.remove('show');
}
function setAuthTab(tab){
  document.querySelectorAll('[data-auth]').forEach(t=>t.classList.toggle('active',t.dataset.auth===tab));
  document.querySelectorAll('#authModal .tab-panel').forEach(p=>p.classList.remove('active'));
  const panel=$(`auth-${tab}`);
  if(panel) panel.classList.add('active');
}

document.querySelectorAll('[data-auth]').forEach(t=>t.addEventListener('click',()=>setAuthTab(t.dataset.auth)));

function signup(){
  const name=$('signupName')?.value.trim()||'';
  const surname=$('signupSurname')?.value.trim()||'';
  const email=$('signupEmail')?.value.trim().toLowerCase()||'';
  const pass=$('signupPassword')?.value||'';
  const pass2=$('signupPassword2')?.value||'';
  const err=$('signupError');
  if(err) err.textContent='';
  if(!name||!surname||!email||!pass||!pass2) return err && (err.textContent='Preencha tudo.');
  if(!gmailOk(email)) return err && (err.textContent='O Gmail precisa terminar com @gmail.com.');
  if(pass.length<4) return err && (err.textContent='A senha precisa ter pelo menos 4 caracteres.');
  if(pass!==pass2) return err && (err.textContent='As senhas não são iguais.');
  const users=getJSON(DB.users,[]);
  const fullName=normalize(name+' '+surname);
  if(users.some(u=>normalize(u.fullName)===fullName)) return err && (err.textContent='Já existe alguém com esse nome e sobrenome.');
  if(users.some(u=>normalize(u.email)===normalize(email))) return err && (err.textContent='Esse Gmail já está em uso.');
  let user={
    id:uid(),
    name,surname,
    fullName:name+' '+surname,
    email,
    password:pass,
    displayName:normalize(email)===normalize(OWNER_EMAIL)?'Mendraki Dono':(name+' '+surname),
    bio:'',
    avatar:makeAvatarData(users.length+1),
    profileEffect:'none',
    muted:false,
    banned:false,
    lastDaily:'',
    stats:getDefaultStats()
  };
  user=userWithDefaults(user);
  users.push(user);
  setJSON(DB.users,users);
  if($('signupName')) $('signupName').value='';
  if($('signupSurname')) $('signupSurname').value='';
  if($('signupEmail')) $('signupEmail').value='';
  if($('signupPassword')) $('signupPassword').value='';
  if($('signupPassword2')) $('signupPassword2').value='';
  toast('Conta criada com sucesso. Agora faça login.');
  setAuthTab('login');
  if($('loginEmail')) $('loginEmail').value=email;
}

function login(){
  const email=$('loginEmail')?.value.trim().toLowerCase()||'';
  const password=$('loginPassword')?.value||'';
  const err=$('loginError');
  if(err) err.textContent='';
  if(!email||!password) return err && (err.textContent='Preencha Gmail e senha.');
  const users=getJSON(DB.users,[]).map(userWithDefaults);
  const user=users.find(u=>normalize(u.email)===normalize(email)&&u.password===password);
  if(!user) return err && (err.textContent='Gmail ou senha incorretos.');
  if(user.banned) return err && (err.textContent='Essa conta foi banida localmente pelo dono.');
  setJSON(DB.session,user);
  updateUserUI();
  closeAuth();
  toast('Login feito com sucesso.');
  playSfx('success');
}

function openLogoutConfirm(){
  $('logoutConfirm1')?.classList.add('show');
}
function openLogoutConfirm2(){
  $('logoutConfirm1')?.classList.remove('show');
  $('logoutConfirm2')?.classList.add('show');
}
function closeLogoutConfirm(){
  $('logoutConfirm1')?.classList.remove('show');
  $('logoutConfirm2')?.classList.remove('show');
}
function logoutFinal(){
  closeLogoutConfirm();
  localStorage.removeItem(DB.session);
  localStorage.removeItem(DB.ownerUnlocked);
  updateUserUI();
  toast('Você saiu da conta.');
}

function updateUserUI(){
  const user=userWithDefaults(currentUser());
  $('authOpenBtn')?.classList.toggle('hidden',!!user);
  $('profileOpenBtn')?.classList.toggle('hidden',!user);
  $('logoutBtn')?.classList.toggle('hidden',!user);
  $('userPill')?.classList.toggle('hidden',!user);

  const ownerBadge=$('topOwnerBadge'), adminNavBtn=$('adminNavBtn');

  if(user){
    if($('topUserName')) $('topUserName').textContent=user.displayName||user.fullName;
    if($('topAvatar')) $('topAvatar').src=user.avatar;
    if($('topCoins')) $('topCoins').textContent=user.stats.coins;
    if($('topLevel')) $('topLevel').textContent=user.stats.level;
  }else{
    if($('topCoins')) $('topCoins').textContent='0';
    if($('topLevel')) $('topLevel').textContent='1';
  }
  if(ownerBadge) ownerBadge.classList.toggle('hidden',!isOwner(user));
  if(adminNavBtn) adminNavBtn.classList.toggle('hidden',!isOwner(user));

  renderHub();
  renderOfficials();
  renderHome();
  renderRanking();
  renderShop();
  renderMissions();
  renderAdminPanel();
  updateAudioButtons();
}

$('authOpenBtn')?.addEventListener('click',()=>openAuth('login'));
$('profileOpenBtn')?.addEventListener('click',openProfile);
$('logoutBtn')?.addEventListener('click',openLogoutConfirm);

function openProfile(){
  const user=userWithDefaults(currentUser());
  if(!user) return toast('Faça login para abrir o perfil.');
  $('profileModal')?.classList.add('show');
  if($('profileDisplayName')) $('profileDisplayName').value=user.displayName||user.fullName;
  if($('profileBio')) $('profileBio').value=user.bio||'';
  if($('profilePreviewAvatar')) $('profilePreviewAvatar').src=user.avatar;
  if($('profilePreviewName')) $('profilePreviewName').textContent=user.displayName||user.fullName;
  if($('profilePreviewMail')) $('profilePreviewMail').textContent=user.email;
  if($('profilePreviewLevel')) $('profilePreviewLevel').textContent='Nível '+user.stats.level+(user.stats.title?' • '+user.stats.title:'');
  $('profilePreviewOwner')?.classList.toggle('hidden',!isOwner(user));
  const ring=$('profilePreviewRing');
  if(ring) ring.style.background=user.stats.frame||'var(--profile-ring)';
  applyPreviewProfileEffect(user.profileEffect||'none');
  renderAvatarGrid();
  renderProfileEffects();
  setProfileTab('dados');
}
function closeProfile(){
  $('profileModal')?.classList.remove('show');
}
function setProfileTab(tab){
  document.querySelectorAll('[data-profile-tab]').forEach(t=>t.classList.toggle('active',t.dataset.profileTab===tab));
  document.querySelectorAll('#profileModal .tab-panel').forEach(p=>p.classList.remove('active'));
  const panel=$('profile-'+tab);
  if(panel) panel.classList.add('active');
}
document.querySelectorAll('[data-profile-tab]').forEach(t=>t.addEventListener('click',()=>setProfileTab(t.dataset.profileTab)));

function saveProfileData(){
  const user=userWithDefaults(currentUser());
  if(!user) return;
  user.displayName=$('profileDisplayName')?.value.trim()||user.fullName;
  user.bio=$('profileBio')?.value.trim()||'';
  if(isOwner(user)) user.displayName='Mendraki Dono';
  persistCurrentUser(user);
  updateUserUI();
  toast('Perfil salvo.');
}

function applyPreviewProfileEffect(effect){
  const ring=$('profilePreviewRing');
  if(!ring) return;
  ring.className='avatar-ring';
  if(effect&&effect!=='none') ring.classList.add('profile-'+effect);
}

function renderAvatarGrid(){
  const grid=$('avatarGrid');
  const user=userWithDefaults(currentUser());
  if(!grid||!user) return;
  grid.innerHTML='';
  for(let i=1;i<=100;i++){
    const img=makeAvatarData(i);
    const tile=document.createElement('button');
    tile.className='pick'+(user.avatar===img?' active':'');
    tile.innerHTML=`<img class="avatar-tile" src="${img}" alt="avatar ${i}">`;
    tile.onclick=()=>{
      const current=userWithDefaults(currentUser());
      current.avatar=img;
      persistCurrentUser(current);
      if($('profilePreviewAvatar')) $('profilePreviewAvatar').src=img;
      renderAvatarGrid();
      updateUserUI();
      toast('Avatar trocado.');
    };
    grid.appendChild(tile);
  }
}

function renderProfileEffects(){
  const grid=$('profileEffectsGrid');
  const user=userWithDefaults(currentUser());
  if(!grid||!user) return;
  grid.innerHTML='';
  profileEffects.forEach(effect=>{
    if(effect.id==='shadow' && !hasItem(user,'effect_shadowplus')) return;
    const item=document.createElement('button');
    item.className='pick'+((user.profileEffect||'none')===effect.id?' active':'');
    item.textContent=effect.name;
    item.onclick=()=>{
      const current=userWithDefaults(currentUser());
      current.profileEffect=effect.id;
      persistCurrentUser(current);
      applyPreviewProfileEffect(effect.id);
      updateUserUI();
      toast('Efeito do perfil salvo.');
    };
    grid.appendChild(item);
  });
}

function makeAvatarData(i){
  const emojis=['🚀','🌌','👑','🤖','🔥','⚡','🎧','🎮','💎','🛸','🌠','🌀'];
  const a=accentColors[i%accentColors.length].replace('#','%23');
  const b=accentColors[(i+3)%accentColors.length].replace('#','%23');
  const emoji=encodeURIComponent(emojis[i%emojis.length]);
  return `data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><defs><linearGradient id='g' x1='0' y1='0' x2='1' y2='1'><stop offset='0%' stop-color='${a}'/><stop offset='100%' stop-color='${b}'/></linearGradient></defs><rect width='100' height='100' rx='28' fill='%230b1630'/><circle cx='50' cy='50' r='34' fill='url(%23g)' opacity='.9'/><text x='50' y='58' font-size='30' text-anchor='middle'>${emoji}</text><text x='50' y='92' font-size='9' fill='white' text-anchor='middle'>WV-${i}</text></svg>`;
}

function toggleCustomizer(){
  $('customizerPanel')?.classList.toggle('show');
}

function renderAccentGrid(){
  const grid=$('accentGrid');
  if(!grid) return;
  const theme=getJSON(DB.theme,{});
  grid.innerHTML='';
  accentColors.forEach(c=>{
    const b=document.createElement('button');
    b.className='pick'+((theme.accent||'#5df2ff')===c?' active':'');
    b.style.background=c;
    b.onclick=()=>{
      saveTheme({...theme,accent:c});
      applyTheme();
      renderAccentGrid();
    };
    grid.appendChild(b);
  });
}

function renderWallpaperGrid(){
  const grid=$('wallpaperGrid');
  if(!grid) return;
  const theme=getJSON(DB.theme,{});
  grid.innerHTML='';
  siteWallpapers.forEach(url=>{
    const item=document.createElement('button');
    item.className='pick'+(theme.wallpaper===url?' active':'');
    item.innerHTML=`<img src="${url}" alt="wallpaper">`;
    item.onclick=()=>{
      saveTheme({...theme,wallpaper:url,uploadedWallpaper:''});
      applyTheme();
      renderWallpaperGrid();
    };
    grid.appendChild(item);
  });
}

const saveTheme=t=>setJSON(DB.theme,t);

function applyTheme(){
  const theme=getJSON(DB.theme,{});
  const accent=theme.accent||'#5df2ff';
  document.documentElement.style.setProperty('--accent',accent);
  document.documentElement.style.setProperty('--cyan',accent);
  const wallpaper=theme.uploadedWallpaper||theme.wallpaper||'';
  if(wallpaper){
    document.documentElement.style.setProperty('--wallpaper',`linear-gradient(rgba(5,10,20,.45), rgba(5,10,20,.45)), url(${wallpaper}) center/cover fixed`);
  }else{
    document.documentElement.style.setProperty('--wallpaper',`radial-gradient(circle at 20% 20%, rgba(93,242,255,0.18), transparent 25%), radial-gradient(circle at 80% 30%, rgba(140,109,255,0.18), transparent 25%), radial-gradient(circle at 50% 80%, rgba(255,98,199,0.15), transparent 25%), linear-gradient(135deg,var(--bg1),var(--bg2),var(--bg3))`);
  }
  document.body.classList.remove('site-glow','site-blur','site-zoom','site-rainbow');
  const fx=theme.effect||'none';
  if(fx!=='none') document.body.classList.add('site-'+fx);
  if($('siteEffectSelect')) $('siteEffectSelect').value=fx;
}

function resetSiteTheme(){
  localStorage.removeItem(DB.theme);
  applyTheme();
  renderAccentGrid();
  renderWallpaperGrid();
  toast('Tema resetado.');
}

$('siteEffectSelect')?.addEventListener('change',e=>{
  const theme=getJSON(DB.theme,{});
  saveTheme({...theme,effect:e.target.value});
  applyTheme();
});

$('wallpaperUpload')?.addEventListener('change',e=>{
  const file=e.target.files?.[0];
  if(!file) return;
  const reader=new FileReader();
  reader.onload=ev=>{
    const theme=getJSON(DB.theme,{});
    saveTheme({...theme,uploadedWallpaper:ev.target.result,wallpaper:''});
    applyTheme();
    renderWallpaperGrid();
    toast('Fundo personalizado salvo.');
  };
  reader.readAsDataURL(file);
});

function runSearch(){
  const q=$('searchInput')?.value.trim().toLowerCase()||'';
  const box=$('searchResult');
  if(!box) return;
  if(!q) return box.textContent='Digite algo para pesquisar.';
  if(q.includes('jogo')||q.includes('arcade')) box.textContent='Resultado: a área Jogos tem Jogo da Velha, Memória Neon, Quiz, Teste de Reação, Snake e Pedra Papel Tesoura.';
  else if(q.includes('loja')||q.includes('comprar')) box.textContent='Resultado: a Loja Cósmica permite comprar títulos, molduras, temas e efeitos com moedas.';
  else if(q.includes('nível')||q.includes('xp')) box.textContent='Resultado: você ganha XP por jogar, vencer, bater recordes e pegar a recompensa diária.';
  else if(q.includes('ranking')||q.includes('classificação')) box.textContent='Resultado: o Hall da Fama mostra os melhores por nível, moedas, snake e vitórias.';
  else if(q.includes('social')||q.includes('hub')||q.includes('chat')) box.textContent='Resultado: o HubSocial tem salas gerais, amigos e chat privado local.';
  else if(q.includes('ia')||q.includes('verseai')) box.textContent='Resultado: a VerseAI local responde perguntas gerais, ajuda com ideias e organiza o WebVerse.';
  else if(q.includes('dono')||q.includes('admin')) box.textContent='Resultado: o Painel Dono aparece para mendraki0801@gmail.com e libera anúncios, avisos e moderação local.';
  else box.textContent=`Resultado: "${q}" ainda não tem categoria específica, mas pode virar uma nova área no WebVerse.`;
}

function askVerseAI(){
  const input=$('aiInput');
  const out=$('aiResponse');
  if(!input||!out) return;
  const q=input.value.trim();
  if(!q) return out.textContent='Escreva uma pergunta para eu responder.';
  out.textContent=verseAIReply(q);
  input.value='';
}

function verseAIReply(q){
  const t=q.toLowerCase(), user=currentUser();
  if(t.includes('quem é você')||t.includes('seu nome')) return 'Eu sou a VerseAI, a assistente do WebVerse. Nesta versão eu funciono localmente, sem internet real.';
  if(t.includes('oi')||t.includes('olá')) return `Olá${user?', '+(user.displayName||user.name):''}. Eu estou pronta para ajudar no WebVerse.`;
  if(t.includes('como crescer')||t.includes('como viralizar')) return 'Para crescer, o WebVerse precisa de identidade forte, atualizações frequentes, jogos divertidos, visual marcante, ranking, recompensas e comunidade ativa.';
  if(t.includes('html')) return 'HTML cria a estrutura da página, como títulos, botões, seções, inputs e áreas do site.';
  if(t.includes('css')) return 'CSS controla aparência, animações, cores, responsividade e estilo visual.';
  if(t.includes('javascript')) return 'JavaScript dá vida ao site: login, jogos, IA local, ranking, loja, áudio e interações.';
  if(t.includes('ia real')) return 'Para colocar IA real no site, depois você conecta uma API de IA via backend. Nesta versão, eu sou uma IA local simulada e forte.';
  if(t.includes('loja')) return 'A loja usa moedas ganhas em partidas, vitórias e recompensa diária. Itens comprados ficam salvos no navegador.';
  if(t.includes('snake')) return 'No Snake você pode escolher dificuldade, ganhar moedas e registrar recordes locais.';
  if(t.includes('ranking')) return 'O ranking local compara os jogadores registrados neste navegador com base em nível, moedas, snake e vitórias.';
  if(t.includes('dinheiro')||t.includes('lucro')) return 'Para lucrar com um site, normalmente você mistura público, conteúdo forte, anúncios, afiliados, recursos premium e comunidade.';
  if(t.includes('ilegal')||t.includes('crime')||t.includes('hackear')) return 'Eu só posso ajudar com coisas seguras, criativas, educativas e legais.';
  return 'Resposta da VerseAI: entendi sua pergunta. Nesta versão eu posso ajudar com ideias, explicações, organização do site, jogos, loja, ranking, perfil e planejamento do WebVerse.';
}

function generateImagePrompt(){
  const idea=$('imageIdea')?.value.trim()||'';
  const box=$('imagePromptResult');
  if(!box) return;
  if(!idea) return box.textContent='Descreva primeiro o que você quer gerar.';
  box.textContent=`Prompt WebVerse:\n${idea}, visual ultra detalhado, iluminação neon azul e roxa, atmosfera futurista, estilo cinematográfico, alta qualidade, composição forte, detalhes brilhantes, cenário digital elegante, identidade visual do WebVerse, arte promocional moderna, fundo tecnológico, foco no personagem/objeto principal.`;
}

function generateContentIdea(){
  const idea=$('contentIdea')?.value.trim()||'';
  const box=$('contentIdeaResult');
  if(!box) return;
  if(!idea) return box.textContent='Escreva uma ideia primeiro.';
  box.textContent=`Ideia criada:\nTema: ${idea}.\nGancho: comece com uma frase forte nos primeiros 5 segundos.\nVisual: use neon, contraste, tipografia grande e elemento central.\nEntrega: transforme em vídeo curto, capa chamativa e post no HubSocial.\nExtra: crie uma versão curta, uma média e uma épica do conteúdo.`;
}

function ensureStores(){
  if(!localStorage.getItem(DB.generalChats)){
    const obj={};
    generalRooms.forEach(r=>obj[r.id]=[]);
    setJSON(DB.generalChats,obj);
  }
  if(!localStorage.getItem(DB.privateChats)) setJSON(DB.privateChats,{});
  if(!localStorage.getItem(DB.official)) setJSON(DB.official,defaultOfficials);
  if(!localStorage.getItem(DB.ads)) setJSON(DB.ads,[]);
  if(!localStorage.getItem(DB.users)) setJSON(DB.users,[]);
  if(!localStorage.getItem(DB.settings)) setJSON(DB.settings,{musicOn:false,sfxOn:true,musicVolume:.06,sfxVolume:.08});
}

function renderHome(){
  const user=userWithDefaults(currentUser());
  const news=[...getJSON(DB.ads,[]).slice(0,2), ...getJSON(DB.official,defaultOfficials).slice(0,3)];
  const newsBox=$('homeNews');
  if(newsBox){
    newsBox.innerHTML='';
    news.forEach(n=>{
      const div=document.createElement('div');
      div.className='news-item';
      div.innerHTML=`<div style="font-weight:bold;margin-bottom:6px;">${escapeHtml(n.title||'Atualização')}</div><div class="small">${escapeHtml(n.text||'')}</div>`;
      newsBox.appendChild(div);
    });
  }
  if(user){
    if($('homeLevel')) $('homeLevel').textContent=user.stats.level;
    if($('homeCoins')) $('homeCoins').textContent=user.stats.coins;
    if($('homeXp')) $('homeXp').textContent=user.stats.xp;
    if($('homeSnakeBest')) $('homeSnakeBest').textContent=user.stats.snakeBest;
    const need=xpNeeded(user.stats.level), pct=Math.min(100,(user.stats.xp/need)*100);
    if($('homeXpFill')) $('homeXpFill').style.width=pct+'%';
    if($('homeXpText')) $('homeXpText').textContent=`${user.stats.xp} / ${need} XP`;
  }else{
    if($('homeLevel')) $('homeLevel').textContent='1';
    if($('homeCoins')) $('homeCoins').textContent='0';
    if($('homeXp')) $('homeXp').textContent='0';
    if($('homeSnakeBest')) $('homeSnakeBest').textContent='0';
    if($('homeXpFill')) $('homeXpFill').style.width='0%';
    if($('homeXpText')) $('homeXpText').textContent='0 / 100 XP';
  }
}

function renderShop(){
  const grid=$('shopGrid');
  if(!grid) return;
  const user=userWithDefaults(currentUser());
  grid.innerHTML='';
  shopItems.forEach(item=>{
    const owned=user?hasItem(user,item.id):false;
    const div=document.createElement('div');
    div.className='shop-item';
    div.innerHTML=`<div class="icon">🛍️</div><h3>${item.name}</h3><p>${item.desc}</p><div class="shop-price">🪙 ${item.price}</div><div style="margin-top:12px;"><button class="shop-buy ${owned?'shop-owned':''}" ${owned?'disabled':''} onclick="buyItem('${item.id}')">${owned?'Comprado':'Comprar'}</button></div>`;
    grid.appendChild(div);
  });
}

function renderRanking(){
  const tbody=$('rankTableBody');
  if(!tbody) return;
  tbody.innerHTML='';
  const users=getJSON(DB.users,[]).map(userWithDefaults).filter(u=>!u.banned);
  users.sort((a,b)=>b.stats.level-a.stats.level||b.stats.coins-a.stats.coins||b.stats.wins-a.stats.wins);
  users.forEach((u,idx)=>{
    const tr=document.createElement('tr');
    tr.innerHTML=`<td>${idx+1}</td><td>${escapeHtml(u.displayName||u.fullName)} ${isOwner(u)?'👑':''}</td><td>${u.stats.level}</td><td>${u.stats.coins}</td><td>${u.stats.snakeBest}</td><td>${u.stats.wins}</td>`;
    tbody.appendChild(tr);
  });
  if(!users.length){
    const tr=document.createElement('tr');
    tr.innerHTML='<td colspan="6">Ainda não há jogadores suficientes.</td>';
    tbody.appendChild(tr);
  }
}

function getMissionStatus(user, mission){
  user=userWithDefaults(user);
  const value=user.stats[mission.key]||0;
  return {value,completed:value>=mission.target,claimed:user.stats.missionsClaimed.includes(mission.id)};
}

function claimMission(missionId){
  const user=userWithDefaults(currentUser());
  if(!user) return toast('Faça login para pegar missões.');
  const mission=missionTemplates.find(m=>m.id===missionId);
  if(!mission) return;
  const status=getMissionStatus(user,mission);
  if(!status.completed) return toast('Missão ainda não concluída.');
  if(status.claimed) return toast('Missão já resgatada.');
  user.stats.missionsClaimed.push(missionId);
  user.stats.coins+=mission.rewardCoins;
  user.stats.xp+=mission.rewardXp;
  persistCurrentUser(user);
  addXp(0);
  playSfx('reward');
  toast(`Missão concluída! +${mission.rewardCoins} moedas e +${mission.rewardXp} XP`);
  renderMissions();
  updateUserUI();
}

function unlockAchievement(name, condition){
  if(!condition) return;
  const user=userWithDefaults(currentUser());
  if(!user) return;
  if(user.stats.achievements.includes(name)) return;
  user.stats.achievements.push(name);
  user.stats.coins+=30;
  persistCurrentUser(user);
  toast(`Conquista desbloqueada: ${name}`);
  renderMissions();
  updateUserUI();
}

function refreshMissionsAndAchievements(){
  const user=userWithDefaults(currentUser());
  if(!user) return;
  unlockAchievement('Primeira vitória',user.stats.wins>=1);
  unlockAchievement('Cobrinha mestre',user.stats.snakeBest>=10);
  unlockAchievement('100 moedas',user.stats.coins>=100);
  unlockAchievement('Gamer dedicado',user.stats.gamesPlayed>=10);
  unlockAchievement('Lenda em ascensão',user.stats.level>=10);
  renderMissions();
  updateUserUI();
}

function renderMissions(){
  const missionBox=$('missionsList'), achBox=$('achievementsList');
  if(!missionBox||!achBox) return;
  missionBox.innerHTML='';
  achBox.innerHTML='';
  const user=userWithDefaults(currentUser());
  if(!user){
    missionBox.innerHTML='<div class="card"><h3>Faça login</h3><p>Entre numa conta para acompanhar suas missões.</p></div>';
    achBox.innerHTML='<div class="card"><h3>Faça login</h3><p>Entre numa conta para acompanhar suas conquistas.</p></div>';
    return;
  }
  missionTemplates.forEach(m=>{
    const st=getMissionStatus(user,m);
    const div=document.createElement('div');
    div.className='mission-item';
    div.innerHTML=`<h3>${m.title}</h3><p>${m.desc}</p><div class="mission-tag">Progresso: ${st.value}/${m.target}</div><p style="margin-top:12px;">Recompensa: 🪙 ${m.rewardCoins} • ⭐ ${m.rewardXp} XP</p><button class="btn ${st.claimed?'':'primary'}" ${st.claimed?'disabled':''} onclick="claimMission('${m.id}')">${st.claimed?'Resgatada':(st.completed?'Resgatar':'Em andamento')}</button>`;
    missionBox.appendChild(div);
  });
  const names=user.stats.achievements;
  if(!names.length){
    achBox.innerHTML='<div class="card"><h3>Nenhuma conquista ainda</h3><p>Jogue mais para desbloquear conquistas.</p></div>';
  } else {
    names.forEach(name=>{
      const div=document.createElement('div');
      div.className='achievement-item';
      div.innerHTML=`<h3>${name}</h3><p>Conquista desbloqueada com sucesso.</p><div class="achievement-tag">Conquistada</div>`;
      achBox.appendChild(div);
    });
  }
}

let selectedGame=null;
function selectGame(game){
  selectedGame=game;
  $('gameStage')?.classList.remove('hidden');
  const title=$('gameTitle'), desc=$('gameDesc'), content=$('gameContent');
  if(!title||!desc||!content) return;

  if(game==='tic'){
    title.textContent='Jogo da Velha';
    desc.textContent='Escolha modo e dificuldade.';
    content.innerHTML=`<div class="row" style="margin-bottom:12px;"><button class="btn" onclick="setTicMode('pvp')">2 jogadores</button><button class="btn" onclick="setTicMode('ai')">Contra IA</button><select id="ticDifficulty" onchange="setTicDifficulty(this.value)"><option value="easy">Fácil</option><option value="medium">Médio</option><option value="hard">Difícil</option></select></div><div class="small" id="ticStatus">Modo atual: 2 jogadores</div><div class="game-grid" id="ticGrid"></div><div class="row"><button class="mini-btn" onclick="resetTicTacToe()">Resetar</button></div>`;
    renderTicTacToe();
  }
  if(game==='memory'){
    title.textContent='Memória Neon';
    desc.textContent='Escolha dificuldade e encontre todos os pares.';
    content.innerHTML=`<div class="row" style="margin-bottom:12px;"><select id="memoryDifficulty" onchange="setMemoryDifficulty(this.value)"><option value="easy">Fácil</option><option value="medium">Médio</option><option value="hard">Difícil</option></select><button class="mini-btn" onclick="startMemoryGame()">Novo jogo</button></div><div class="small" id="memoryInfo">Jogadas: 0</div><div class="memory-grid" id="memoryGrid"></div>`;
    startMemoryGame();
  }
  if(game==='quiz'){
    title.textContent='Quiz Rápido';
    desc.textContent='Responda perguntas e escolha dificuldade.';
    content.innerHTML=`<div class="row" style="margin-bottom:12px;"><select id="quizDifficulty" onchange="startQuizGame()"><option value="easy">Fácil</option><option value="medium">Médio</option><option value="hard">Difícil</option></select><button class="mini-btn" onclick="startQuizGame()">Novo quiz</button></div><div class="ai-response-box" id="quizBox">Carregando quiz...</div>`;
    startQuizGame();
  }
  if(game==='reaction'){
    title.textContent='Teste de Reação';
    desc.textContent='Clique quando a caixa ficar verde.';
    content.innerHTML=`<div class="row" style="margin-bottom:12px;"><button class="mini-btn" onclick="startReactionGame()">Começar</button></div><div class="small" id="reactionInfo">Clique em começar.</div><div class="reaction-box" id="reactionBox" onclick="handleReactionClick()">Esperando</div>`;
    resetReactionGame();
  }
  if(game==='snake'){
    title.textContent='Snake Neon';
    desc.textContent='Controle com setas ou WASD.';
    content.innerHTML=`<div class="snake-wrap"><div class="row"><select id="snakeDifficulty" onchange="setSnakeDifficulty(this.value)"><option value="easy">Fácil</option><option value="medium">Médio</option><option value="hard">Difícil</option></select><button class="mini-btn" onclick="startSnakeGame()">Começar Snake</button><button class="btn" onclick="stopSnakeGame()">Parar</button></div><div class="small" id="snakeInfo">Pontuação: 0 | Melhor: 0</div><canvas id="snakeCanvas" width="420" height="420"></canvas></div>`;
    initSnakeCanvas();
  }
  if(game==='rps'){
    title.textContent='Pedra Papel Tesoura';
    desc.textContent='Contra IA com dificuldade e série.';
    content.innerHTML=`<div class="row" style="margin-bottom:12px;"><select id="rpsDifficulty" onchange="setRpsDifficulty(this.value)"><option value="easy">Fácil</option><option value="medium">Médio</option><option value="hard">Difícil</option></select><select id="rpsSeries" onchange="setRpsSeries(this.value)"><option value="3">Melhor de 3</option><option value="5">Melhor de 5</option></select><button class="mini-btn" onclick="resetRps()">Resetar série</button></div><div class="small" id="rpsInfo">Você 0 x 0 IA</div><div class="rps-choices"><button class="btn" onclick="playRps('pedra')">✊ Pedra</button><button class="btn" onclick="playRps('papel')">✋ Papel</button><button class="btn" onclick="playRps('tesoura')">✌️ Tesoura</button></div><div class="ai-response-box" id="rpsResult" style="margin-top:12px;">Escolha uma jogada.</div>`;
    resetRps();
  }
  playSfx('click');
}

function backToGames(){
  $('gameStage')?.classList.add('hidden');
  selectedGame=null;
  stopSnakeGame();
}

let ticBoard=Array(9).fill(''), ticTurn='X', ticMode='pvp', ticDifficulty='easy';

function renderTicTacToe(){
  const grid=$('ticGrid');
  if(!grid) return;
  grid.innerHTML='';
  ticBoard.forEach((cell,i)=>{
    const b=document.createElement('button');
    b.className='game-cell';
    b.textContent=cell;
    b.onclick=()=>playTic(i);
    grid.appendChild(b);
  });
}

function setTicMode(mode){
  ticMode=mode;
  if($('ticStatus')) $('ticStatus').textContent='Modo atual: '+(mode==='ai'?'Contra IA':'2 jogadores')+' | Dificuldade: '+ticDifficulty.toUpperCase();
  resetTicTacToe();
}

function setTicDifficulty(level){
  ticDifficulty=level;
  if($('ticStatus')) $('ticStatus').textContent='Modo atual: '+(ticMode==='ai'?'Contra IA':'2 jogadores')+' | Dificuldade: '+ticDifficulty.toUpperCase();
  resetTicTacToe();
}

function resetTicTacToe(){
  ticBoard=Array(9).fill('');
  ticTurn='X';
  renderTicTacToe();
}

function ticWinner(board){
  const wins=[[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
  for(const [a,b,c] of wins) if(board[a]&&board[a]===board[b]&&board[a]===board[c]) return board[a];
  if(board.every(Boolean)) return 'draw';
  return null;
}

function playTic(i){
  if(ticBoard[i]||ticWinner(ticBoard)) return;
  ticBoard[i]=ticTurn;
  renderTicTacToe();
  const result=ticWinner(ticBoard);
  if(result) return finishTic(result);
  ticTurn=ticTurn==='X'?'O':'X';
  if(ticMode==='ai'&&ticTurn==='O'){
    setTimeout(()=>{
      const move=getAIMove();
      if(move!==undefined){
        ticBoard[move]='O';
        renderTicTacToe();
        const r=ticWinner(ticBoard);
        if(r) finishTic(r);
        else ticTurn='X';
      }
    },320);
  }
}

function getAIMove(){
  const free=ticBoard.map((v,idx)=>v?null:idx).filter(v=>v!==null);
  if(!free.length) return undefined;
  if(ticDifficulty==='easy') return free[Math.floor(Math.random()*free.length)];
  if(ticDifficulty==='medium'){
    for(const i of free){
      const temp=[...ticBoard];
      temp[i]='O';
      if(ticWinner(temp)==='O') return i;
    }
    if(Math.random()<.55 && !ticBoard[4]) return 4;
    return free[Math.floor(Math.random()*free.length)];
  }
  for(const i of free){
    const temp=[...ticBoard];
    temp[i]='O';
    if(ticWinner(temp)==='O') return i;
  }
  for(const i of free){
    const temp=[...ticBoard];
    temp[i]='X';
    if(ticWinner(temp)==='X') return i;
  }
  if(!ticBoard[4]) return 4;
  const corners=[0,2,6,8].filter(i=>!ticBoard[i]);
  if(corners.length) return corners[Math.floor(Math.random()*corners.length)];
  return free[Math.floor(Math.random()*free.length)];
}

function finishTic(result){
  recordGamePlayed();
  if(result==='draw'){
    playSfx('lose');
    toast('Empate no jogo da velha.');
  } else {
    if(result==='X'||(result==='O'&&ticMode==='pvp')) recordWin('ttt');
    playSfx('win');
    toast((result==='O'&&ticMode==='ai')?'A IA venceu.':`Jogador ${result} venceu.`);
  }
}

let memorySymbols=[], memoryOpen=[], memoryLock=false, memoryMoves=0, memoryDifficulty='easy';

function setMemoryDifficulty(level){
  memoryDifficulty=level;
  startMemoryGame();
}

function startMemoryGame(){
  let base=['🚀','🌌','👑','🤖','🔥','🎮'];
  if(memoryDifficulty==='medium') base=['🚀','🌌','👑','🤖','🔥','🎮','⚡','💎'];
  if(memoryDifficulty==='hard') base=['🚀','🌌','👑','🤖','🔥','🎮','⚡','💎','🛸','🌠'];
  memorySymbols=[...base,...base].sort(()=>Math.random()-.5).map((s,i)=>({id:i,symbol:s,open:false,done:false}));
  memoryOpen=[];
  memoryLock=false;
  memoryMoves=0;
  renderMemory();
}

function renderMemory(){
  const grid=$('memoryGrid');
  if(!grid) return;
  if($('memoryInfo')) $('memoryInfo').textContent='Jogadas: '+memoryMoves+' | Dificuldade: '+memoryDifficulty.toUpperCase();
  grid.innerHTML='';
  memorySymbols.forEach(card=>{
    const b=document.createElement('button');
    b.className='memory-card';
    b.textContent=(card.open||card.done)?card.symbol:'✦';
    b.onclick=()=>openMemory(card.id);
    grid.appendChild(b);
  });
}

function openMemory(id){
  if(memoryLock) return;
  const card=memorySymbols.find(c=>c.id===id);
  if(!card||card.done||card.open) return;
  card.open=true;
  memoryOpen.push(card);
  renderMemory();
  if(memoryOpen.length===2){
    memoryMoves++;
    memoryLock=true;
    renderMemory();
    let delay=memoryDifficulty==='hard'?500:700;
    setTimeout(()=>{
      const [a,b]=memoryOpen;
      if(a.symbol===b.symbol){
        a.done=true;
        b.done=true;
        playSfx('success');
      } else {
        a.open=false;
        b.open=false;
      }
      memoryOpen=[];
      memoryLock=false;
      renderMemory();
      if(memorySymbols.every(c=>c.done)){
        recordGamePlayed();
        recordWin('memory');
        playSfx('win');
        toast('Você venceu o Memory Neon!');
      }
    },delay);
  }
}

const quizData={
  easy:[
    {q:'Qual linguagem estrutura uma página web?',a:['HTML','CSS','SQL','Java'],c:0},
    {q:'Qual jogo do site usa uma cobrinha?',a:['Quiz','Snake','Memória','RPS'],c:1}
  ],
  medium:[
    {q:'Qual parte cuida do estilo da página?',a:['HTML','CSS','PHP','SQL'],c:1},
    {q:'Qual armazenamento este projeto usa na versão local?',a:['MySQL','Firebase','localStorage','MongoDB'],c:2}
  ],
  hard:[
    {q:'Qual camada protege credenciais de admin num site real?',a:['CSS','Cliente local','Servidor/backend','Wallpaper'],c:2},
    {q:'O que este projeto ainda precisa para multiplayer real?',a:['Só CSS','Só HTML','Backend + banco','Só avatar'],c:2}
  ]
};
let currentQuiz=null;

function startQuizGame(){
  const level=$('quizDifficulty')?.value||'easy';
  const pack=quizData[level];
  currentQuiz=pack[Math.floor(Math.random()*pack.length)];
  renderQuiz(level);
}

function renderQuiz(level){
  const box=$('quizBox');
  if(!box||!currentQuiz) return;
  box.innerHTML=`<div style="font-size:20px;font-weight:bold;margin-bottom:8px;">Pergunta (${level.toUpperCase()})</div><div style="margin-bottom:12px;">${currentQuiz.q}</div><div class="quiz-answers">${currentQuiz.a.map((ans,i)=>`<button class="btn" onclick="answerQuiz(${i})">${ans}</button>`).join('')}</div>`;
}

function answerQuiz(i){
  if(!currentQuiz) return;
  recordGamePlayed();
  if(i===currentQuiz.c){
    recordWin('quiz');
    playSfx('win');
    toast('Resposta correta!');
  } else {
    playSfx('lose');
    toast('Resposta errada.');
  }
  startQuizGame();
}

let reactionStart=null, reactionReady=false, reactionTimeout=null;

function resetReactionGame(){
  reactionStart=null;
  reactionReady=false;
  clearTimeout(reactionTimeout);
  const box=$('reactionBox'), info=$('reactionInfo');
  if(box){
    box.textContent='Esperando';
    box.style.background='rgba(255,255,255,.06)';
  }
  if(info) info.textContent='Clique em começar.';
}

function startReactionGame(){
  resetReactionGame();
  const box=$('reactionBox'), info=$('reactionInfo');
  if(info) info.textContent='Espere a caixa mudar de cor...';
  reactionTimeout=setTimeout(()=>{
    reactionReady=true;
    reactionStart=performance.now();
    if(box){
      box.textContent='CLIQUE!';
      box.style.background='rgba(0,255,153,.22)';
    }
  },1200+Math.random()*2200);
}

function handleReactionClick(){
  const box=$('reactionBox'), info=$('reactionInfo');
  if(!reactionStart&&!reactionReady){
    if(info) info.textContent='Cedo demais. Clique em começar de novo.';
    if(box){
      box.textContent='Muito cedo';
      box.style.background='rgba(255,77,109,.18)';
    }
    clearTimeout(reactionTimeout);
    playSfx('lose');
    return;
  }
  if(reactionReady){
    const ms=Math.round(performance.now()-reactionStart);
    if(info) info.textContent=`Seu tempo: ${ms} ms`;
    if(box){
      box.textContent=ms+' ms';
      box.style.background='rgba(93,242,255,.18)';
    }
    reactionReady=false;
    reactionStart=null;
    recordGamePlayed();
    setReactionBest(ms);
    addCoins(10);
    addXp(10);
    playSfx('success');
  }
}

let snakeCanvas,snakeCtx,snakeInterval=null,snakeCell=21,snake=[],snakeDir={x:1,y:0},snakeNextDir={x:1,y:0},snakeFood={x:5,y:5},snakeScore=0,snakeDifficulty='easy';

function initSnakeCanvas(){
  snakeCanvas=$('snakeCanvas');
  if(!snakeCanvas) return;
  snakeCtx=snakeCanvas.getContext('2d');
  drawSnakeBoard();
}

function setSnakeDifficulty(level){
  snakeDifficulty=level;
}

function startSnakeGame(){
  stopSnakeGame();
  initSnakeCanvas();
  snake=[{x:8,y:10},{x:7,y:10},{x:6,y:10}];
  snakeDir={x:1,y:0};
  snakeNextDir={x:1,y:0};
  snakeScore=0;
  placeSnakeFood();
  updateSnakeInfo();
  let speed=180;
  if(snakeDifficulty==='medium') speed=120;
  if(snakeDifficulty==='hard') speed=85;
  snakeInterval=setInterval(stepSnake,speed);
  drawSnakeBoard();
  playSfx('success');
}

function stopSnakeGame(){
  clearInterval(snakeInterval);
  snakeInterval=null;
}

function placeSnakeFood(){
  const size=20;
  do{
    snakeFood={x:Math.floor(Math.random()*size),y:Math.floor(Math.random()*size)};
  } while(snake.some(s=>s.x===snakeFood.x&&s.y===snakeFood.y));
}

function stepSnake(){
  snakeDir=snakeNextDir;
  const head={x:snake[0].x+snakeDir.x,y:snake[0].y+snakeDir.y};
  const size=20;
  if(head.x<0||head.y<0||head.x>=size||head.y>=size||snake.some(seg=>seg.x===head.x&&seg.y===head.y)){
    stopSnakeGame();
    recordGamePlayed();
    setSnakeBest(snakeScore);
    if(snakeScore>=3){
      addCoins(10+snakeScore*2);
      addXp(15+snakeScore*2);
    }
    playSfx('lose');
    toast('Fim de jogo no Snake. Pontuação: '+snakeScore);
    return;
  }
  snake.unshift(head);
  if(head.x===snakeFood.x&&head.y===snakeFood.y){
    snakeScore++;
    addCoins(5);
    addXp(5);
    placeSnakeFood();
    playSfx('coin');
  } else {
    snake.pop();
  }
  updateSnakeInfo();
  drawSnakeBoard();
}

function updateSnakeInfo(){
  const user=userWithDefaults(currentUser());
  const best=user?user.stats.snakeBest:0;
  const info=$('snakeInfo');
  if(info) info.textContent=`Pontuação: ${snakeScore} | Melhor: ${best} | Dificuldade: ${snakeDifficulty.toUpperCase()}`;
}

function drawSnakeBoard(){
  if(!snakeCtx) return;
  const size=20;
  snakeCtx.clearRect(0,0,420,420);
  for(let y=0;y<size;y++){
    for(let x=0;x<size;x++){
      snakeCtx.fillStyle=(x+y)%2===0?'#0c1933':'#091427';
      snakeCtx.fillRect(x*snakeCell,y*snakeCell,snakeCell,snakeCell);
    }
  }
  snakeCtx.fillStyle='#ff62c7';
  snakeCtx.beginPath();
  snakeCtx.arc(snakeFood.x*snakeCell+snakeCell/2,snakeFood.y*snakeCell+snakeCell/2,snakeCell/2.8,0,Math.PI*2);
  snakeCtx.fill();
  snake.forEach((seg,idx)=>{
    snakeCtx.fillStyle=idx===0?'#5df2ff':'#46b3ff';
    snakeCtx.fillRect(seg.x*snakeCell+2,seg.y*snakeCell+2,snakeCell-4,snakeCell-4);
  });
}

window.addEventListener('keydown',e=>{
  const k=e.key.toLowerCase();
  if(k==='arrowup'||k==='w'){if(snakeDir.y!==1) snakeNextDir={x:0,y:-1};}
  if(k==='arrowdown'||k==='s'){if(snakeDir.y!==-1) snakeNextDir={x:0,y:1};}
  if(k==='arrowleft'||k==='a'){if(snakeDir.x!==1) snakeNextDir={x:-1,y:0};}
  if(k==='arrowright'||k==='d'){if(snakeDir.x!==-1) snakeNextDir={x:1,y:0};}
});

let rpsDifficulty='easy', rpsSeries=3, rpsScorePlayer=0, rpsScoreAi=0;

function setRpsDifficulty(level){rpsDifficulty=level; resetRps();}
function setRpsSeries(value){rpsSeries=parseInt(value,10); resetRps();}
function resetRps(){
  rpsScorePlayer=0;
  rpsScoreAi=0;
  updateRpsInfo();
  const box=$('rpsResult');
  if(box) box.textContent='Escolha uma jogada.';
}
function updateRpsInfo(){
  const el=$('rpsInfo');
  if(el) el.textContent=`Você ${rpsScorePlayer} x ${rpsScoreAi} IA | ${rpsDifficulty.toUpperCase()} | Melhor de ${rpsSeries}`;
}
function aiRpsChoice(player){
  const opts=['pedra','papel','tesoura'];
  if(rpsDifficulty==='easy') return opts[Math.floor(Math.random()*3)];
  if(rpsDifficulty==='medium'){
    if(Math.random()<0.4){
      if(player==='pedra') return 'papel';
      if(player==='papel') return 'tesoura';
      return 'pedra';
    }
    return opts[Math.floor(Math.random()*3)];
  }
  if(player==='pedra') return 'papel';
  if(player==='papel') return 'tesoura';
  return 'pedra';
}
function rpsWinner(p,a){
  if(p===a) return 'draw';
  if((p==='pedra'&&a==='tesoura')||(p==='papel'&&a==='pedra')||(p==='tesoura'&&a==='papel')) return 'player';
  return 'ai';
}
function playRps(choice){
  const ai=aiRpsChoice(choice), result=rpsWinner(choice,ai), out=$('rpsResult');
  if(result==='draw'){
    if(out) out.textContent=`Você escolheu ${choice}. A IA escolheu ${ai}. Empate.`;
    playSfx('click');
  } else if(result==='player'){
    rpsScorePlayer++;
    if(out) out.textContent=`Você escolheu ${choice}. A IA escolheu ${ai}. Você venceu a rodada!`;
    playSfx('win');
  } else {
    rpsScoreAi++;
    if(out) out.textContent=`Você escolheu ${choice}. A IA escolheu ${ai}. A IA venceu a rodada.`;
    playSfx('lose');
  }
  updateRpsInfo();
  if(rpsScorePlayer>=Math.ceil(rpsSeries/2)||rpsScoreAi>=Math.ceil(rpsSeries/2)){
    recordGamePlayed();
    if(rpsScorePlayer>rpsScoreAi){
      recordWin('rps');
      addCoins(rpsDifficulty==='hard'?35:rpsDifficulty==='medium'?20:10);
      toast('Você venceu a série no Pedra Papel Tesoura!');
    } else {
      toast('A IA venceu a série no Pedra Papel Tesoura.');
    }
    resetRps();
  }
}

function renderHub(){
  ensureStores();
  renderGeneralRooms();
  renderFriends();
  renderFriendResults();
  renderMessages();
}

function renderGeneralRooms(){
  const box=$('generalRoomList');
  if(!box) return;
  box.innerHTML='';
  generalRooms.forEach(room=>{
    const item=document.createElement('div');
    item.className='list-item'+(currentChatMode==='general'&&currentGeneralRoom===room.id?' active':'');
    item.innerHTML=`<div>💬</div><div><div>${room.title}</div><div class="small">${room.desc}</div></div>`;
    item.onclick=()=>{
      currentChatMode='general';
      currentPrivateFriendId=null;
      currentGeneralRoom=room.id;
      renderHub();
    };
    box.appendChild(item);
  });
}

function renderFriends(){
  const user=userWithDefaults(currentUser()), list=$('friendList');
  if(!list) return;
  list.innerHTML='';
  if(!user){
    list.innerHTML='<div class="small">Faça login para ter amigos.</div>';
    return;
  }
  const users=getJSON(DB.users,[]).map(userWithDefaults);
  const friends=users.filter(u=>(user.friends||[]).includes(u.id));
  if(!friends.length){
    list.innerHTML='<div class="small">Você ainda não adicionou amigos.</div>';
    return;
  }
  friends.forEach(friend=>{
    const item=document.createElement('div');
    item.className='list-item'+(currentChatMode==='private'&&currentPrivateFriendId===friend.id?' active':'');
    item.innerHTML=`<img class="tiny-avatar" src="${friend.avatar}"><div><div>${friend.displayName||friend.fullName}</div><div class="small">Chat privado</div></div>`;
    item.onclick=()=>{
      currentChatMode='private';
      currentPrivateFriendId=friend.id;
      renderHub();
    };
    list.appendChild(item);
  });
}

function findFriend(){
  renderFriendResults($('friendSearchInput')?.value.trim()||'');
}

function renderFriendResults(query=''){
  const user=userWithDefaults(currentUser()), list=$('friendResultList');
  if(!list) return;
  list.innerHTML='';
  if(!user){
    list.innerHTML='<div class="small">Faça login para procurar amigos.</div>';
    return;
  }
  const users=getJSON(DB.users,[]).map(userWithDefaults).filter(u=>u.id!==user.id&&!u.banned);
  const filtered=query?users.filter(u=>normalize(u.displayName||u.fullName).includes(normalize(query))||normalize(u.email).includes(normalize(query))):users.slice(0,5);
  if(!filtered.length){
    list.innerHTML='<div class="small">Nenhum usuário encontrado.</div>';
    return;
  }
  filtered.forEach(u=>{
    const already=(user.friends||[]).includes(u.id);
    const item=document.createElement('div');
    item.className='list-item';
    item.innerHTML=`<img class="tiny-avatar" src="${u.avatar}"><div style="flex:1;"><div>${u.displayName||u.fullName}</div><div class="small">${u.email}</div></div><button class="btn">${already?'Já é amigo':'Adicionar'}</button>`;
    item.querySelector('button').onclick=e=>{
      e.stopPropagation();
      if(!already) addFriend(u.id);
    };
    list.appendChild(item);
  });
}

function addFriend(friendId){
  const user=userWithDefaults(currentUser());
  if(!user) return toast('Faça login primeiro.');
  const users=getJSON(DB.users,[]).map(userWithDefaults);
  const me=users.find(u=>u.id===user.id), friend=users.find(u=>u.id===friendId);
  if(!me||!friend) return;
  me.friends=me.friends||[];
  friend.friends=friend.friends||[];
  if(!me.friends.includes(friendId)) me.friends.push(friendId);
  if(!friend.friends.includes(me.id)) friend.friends.push(me.id);
  setJSON(DB.users,users);
  setJSON(DB.session,me);
  updateUserUI();
  toast('Amizade criada.');
  currentChatMode='private';
  currentPrivateFriendId=friendId;
  renderHub();
}

const getPrivateKey=(a,b)=>[a,b].sort().join('_');

function renderMessages(){
  const title=$('chatTitle'), subtitle=$('chatSubtitle'), area=$('chatMessages');
  if(!area||!title||!subtitle) return;
  area.innerHTML='';
  const me=userWithDefaults(currentUser());
  let messages=[];

  if(currentChatMode==='general'){
    const rooms=getJSON(DB.generalChats,{});
    messages=rooms[currentGeneralRoom]||[];
    const room=generalRooms.find(r=>r.id===currentGeneralRoom);
    title.textContent=room.title;
    subtitle.textContent=room.desc;
  } else {
    const users=getJSON(DB.users,[]).map(userWithDefaults);
    const friend=users.find(u=>u.id===currentPrivateFriendId);
    title.textContent=friend?`Chat com ${friend.displayName||friend.fullName}`:'Chat privado';
    subtitle.textContent='Só você e esse amigo.';
    if(me&&friend){
      const chats=getJSON(DB.privateChats,{});
      messages=chats[getPrivateKey(me.id,friend.id)]||[];
    }
  }

  if(!messages.length) area.innerHTML='<div class="small">Ainda não há mensagens aqui.</div>';
  messages.forEach(msg=>{
    const div=document.createElement('div');
    div.className='msg '+(me&&msg.userId===me.id?'self':'other');
    div.innerHTML=`<div class="meta">${msg.name} • ${msg.time}</div><div>${escapeHtml(msg.text)}</div>`;
    area.appendChild(div);
  });
  area.scrollTop=area.scrollHeight;
}

function sendChatMessage(){
  const me=userWithDefaults(currentUser());
  if(!me) return toast('Faça login para enviar mensagem.');
  if(me.muted) return toast('Sua conta está silenciada localmente pelo dono.');
  const input=$('chatInput');
  const text=input?.value.trim()||'';
  if(!text) return;
  const msg={userId:me.id,name:me.displayName||me.fullName,text,time:nowTime()};
  if(currentChatMode==='general'){
    const rooms=getJSON(DB.generalChats,{});
    rooms[currentGeneralRoom]=rooms[currentGeneralRoom]||[];
    rooms[currentGeneralRoom].push(msg);
    setJSON(DB.generalChats,rooms);
  } else {
    if(!currentPrivateFriendId) return toast('Escolha um amigo primeiro.');
    const chats=getJSON(DB.privateChats,{});
    const key=getPrivateKey(me.id,currentPrivateFriendId);
    chats[key]=chats[key]||[];
    chats[key].push(msg);
    setJSON(DB.privateChats,chats);
  }
  if(input) input.value='';
  renderMessages();
  playSfx('click');
}

function clearCurrentChat(){
  const me=userWithDefaults(currentUser());
  if(!me) return toast('Faça login.');
  if(currentChatMode==='general'){
    const rooms=getJSON(DB.generalChats,{});
    rooms[currentGeneralRoom]=[];
    setJSON(DB.generalChats,rooms);
  } else if(currentPrivateFriendId){
    const chats=getJSON(DB.privateChats,{});
    chats[getPrivateKey(me.id,currentPrivateFriendId)]=[];
    setJSON(DB.privateChats,chats);
  }
  renderMessages();
  toast('Chat atual limpo.');
}

function renderOfficials(){
  const data=getJSON(DB.official,defaultOfficials), ads=getJSON(DB.ads,[]), list=$('officialList');
  if(!list) return;
  list.innerHTML='';
  ads.forEach(ad=>{
    const item=document.createElement('div');
    item.className='official-item';
    item.innerHTML=`<div style="font-weight:bold;font-size:20px;margin-bottom:6px;">📢 ${escapeHtml(ad.title)}</div><div class="small" style="margin-bottom:8px;">Anúncio interno</div><div>${escapeHtml(ad.text)}</div>`;
    list.appendChild(item);
  });
  data.forEach(post=>{
    const item=document.createElement('div');
    item.className='official-item';
    item.innerHTML=`<div style="font-weight:bold;font-size:20px;margin-bottom:6px;">${escapeHtml(post.title)}</div><div class="small" style="margin-bottom:8px;">${escapeHtml(post.date)}</div><div>${escapeHtml(post.text)}</div>`;
    list.appendChild(item);
  });
}

function unlockOwnerPanel(){
  const user=currentUser(), pin=$('ownerPinInput')?.value.trim()||'', err=$('ownerPinError');
  if(err) err.textContent='';
  if(!isOwner(user)){ if(err) err.textContent='Só a conta do dono pode entrar aqui.'; return; }
  if(pin!==OWNER_PIN){ if(err) err.textContent='PIN incorreto.'; return; }
  localStorage.setItem(DB.ownerUnlocked,'1');
  renderAdminPanel();
  toast('Painel do dono liberado.');
}

function renderAdminPanel(){
  const user=currentUser(), locked=$('adminLockedBox'), area=$('adminArea');
  if(!locked||!area) return;
  if(!isOwner(user)){
    locked.classList.remove('hidden');
    area.classList.add('hidden');
    if($('ownerPinError')) $('ownerPinError').textContent='Entre com a conta do dono para usar esse painel.';
    return;
  }
  if(!isOwnerUnlocked()){
    locked.classList.remove('hidden');
    area.classList.add('hidden');
    if($('ownerPinError')) $('ownerPinError').textContent='';
    return;
  }
  locked.classList.add('hidden');
  area.classList.remove('hidden');
  const users=getJSON(DB.users,[]).map(userWithDefaults), general=getJSON(DB.generalChats,{}), priv=getJSON(DB.privateChats,{}), ads=getJSON(DB.ads,[]);
  let msgCount=0;
  Object.values(general).forEach(arr=>msgCount+=arr.length);
  Object.values(priv).forEach(arr=>msgCount+=arr.length);
  if($('adminUserCount')) $('adminUserCount').textContent=users.length;
  if($('adminMsgCount')) $('adminMsgCount').textContent=msgCount;
  if($('adminAdCount')) $('adminAdCount').textContent=ads.length;
  const tbody=$('adminUsersTable');
  if(!tbody) return;
  tbody.innerHTML='';
  users.forEach(u=>{
    const tr=document.createElement('tr');
    let status=[];
    if(isOwner(u)) status.push('DONO');
    if(u.banned) status.push('BANIDO');
    if(u.muted) status.push('SILENCIADO');
    if(!status.length) status.push('NORMAL');
    tr.innerHTML=`<td>${escapeHtml(u.displayName||u.fullName)}</td><td>${escapeHtml(u.email)}</td><td>${status.join(' / ')}</td><td>${!isOwner(u)?`<div class="row"><button class="btn" onclick="toggleMuteUser('${u.id}')">${u.muted?'Desmutar':'Silenciar'}</button><button class="btn danger" onclick="toggleBanUser('${u.id}')">${u.banned?'Desbanir':'Banir'}</button></div>`:'<span class="small">Conta protegida</span>'}</td>`;
    tbody.appendChild(tr);
  });
}

function toggleMuteUser(userId){
  const me=currentUser();
  if(!isOwner(me)||!isOwnerUnlocked()) return;
  const users=getJSON(DB.users,[]).map(userWithDefaults);
  const target=users.find(u=>u.id===userId);
  if(!target||isOwner(target)) return;
  target.muted=!target.muted;
  setJSON(DB.users,users);
  const session=currentUser();
  if(session&&session.id===userId) setJSON(DB.session,target);
  renderAdminPanel();
  toast(target.muted?'Usuário silenciado.':'Usuário desmutado.');
}

function toggleBanUser(userId){
  const me=currentUser();
  if(!isOwner(me)||!isOwnerUnlocked()) return;
  const users=getJSON(DB.users,[]).map(userWithDefaults);
  const target=users.find(u=>u.id===userId);
  if(!target||isOwner(target)) return;
  target.banned=!target.banned;
  setJSON(DB.users,users);
  const session=currentUser();
  if(session&&session.id===userId&&target.banned) localStorage.removeItem(DB.session);
  else if(session&&session.id===userId) setJSON(DB.session,target);
  renderAdminPanel();
  updateUserUI();
  toast(target.banned?'Usuário banido localmente.':'Usuário desbanido.');
}

function createAnnouncement(){
  const me=currentUser();
  if(!isOwner(me)||!isOwnerUnlocked()) return;
  const title=$('adTitle')?.value.trim()||'', text=$('adText')?.value.trim()||'';
  if(!title||!text) return toast('Preencha o título e o texto do anúncio.');
  const ads=getJSON(DB.ads,[]);
  ads.unshift({title,text});
  setJSON(DB.ads,ads);
  if($('adTitle')) $('adTitle').value='';
  if($('adText')) $('adText').value='';
  renderAdminPanel();
  renderOfficials();
  renderHome();
  toast('Anúncio publicado.');
}

function createOfficialPost(){
  const me=currentUser();
  if(!isOwner(me)||!isOwnerUnlocked()) return;
  const title=$('officialTitleInput')?.value.trim()||'', text=$('officialTextInput')?.value.trim()||'';
  if(!title||!text) return toast('Preencha o título e o texto do aviso.');
  const posts=getJSON(DB.official,defaultOfficials);
  posts.unshift({title,text,date:'Agora'});
  setJSON(DB.official,posts);
  if($('officialTitleInput')) $('officialTitleInput').value='';
  if($('officialTextInput')) $('officialTextInput').value='';
  renderOfficials();
  renderHome();
  toast('Aviso oficial publicado.');
}

$('aiInput')?.addEventListener('keydown',e=>{if(e.key==='Enter') askVerseAI();});
$('searchInput')?.addEventListener('keydown',e=>{if(e.key==='Enter') runSearch();});
$('chatInput')?.addEventListener('keydown',e=>{if(e.key==='Enter') sendChatMessage();});

let audioCtx=null, musicGain=null, musicOsc1=null, musicOsc2=null, settings=null;

function getAudioSettings(){
  settings=getJSON(DB.settings,{musicOn:false,sfxOn:true,musicVolume:.06,sfxVolume:.08});
  return settings;
}
function saveAudioSettings(){
  setJSON(DB.settings,settings);
}
function ensureAudio(){
  if(audioCtx) return;
  audioCtx=new (window.AudioContext||window.webkitAudioContext)();
  musicGain=audioCtx.createGain();
  musicGain.gain.value=0;
  musicGain.connect(audioCtx.destination);

  musicOsc1=audioCtx.createOscillator();
  musicOsc2=audioCtx.createOscillator();
  musicOsc1.type='sine';
  musicOsc2.type='triangle';
  musicOsc1.frequency.value=220;
  musicOsc2.frequency.value=329.63;

  const g1=audioCtx.createGain(), g2=audioCtx.createGain();
  g1.gain.value=.025;
  g2.gain.value=.018;
  musicOsc1.connect(g1);
  musicOsc2.connect(g2);
  g1.connect(musicGain);
  g2.connect(musicGain);
  musicOsc1.start();
  musicOsc2.start();

  let step=0;
  setInterval(()=>{
    if(!audioCtx) return;
    const notes=[220,246.94,261.63,293.66,329.63,349.23,392];
    const notes2=[329.63,392,440,392,349.23,329.63,293.66];
    if(settings?.musicOn){
      musicOsc1.frequency.setTargetAtTime(notes[step%notes.length], audioCtx.currentTime, .05);
      musicOsc2.frequency.setTargetAtTime(notes2[step%notes2.length], audioCtx.currentTime, .05);
    }
    step++;
  },800);
}

function updateAudioButtons(){
  settings=getAudioSettings();
  if($('musicToggleBtn')) $('musicToggleBtn').textContent=settings.musicOn?'🎵 Música ON':'🎵 Música OFF';
  if($('sfxToggleBtn')) $('sfxToggleBtn').textContent=settings.sfxOn?'🔊 Som ON':'🔇 Som OFF';
  if(musicGain) musicGain.gain.setTargetAtTime(settings.musicOn?settings.musicVolume:0, audioCtx.currentTime, .1);
}

function toggleMusic(){
  getAudioSettings();
  ensureAudio();
  if(audioCtx.state==='suspended') audioCtx.resume();
  settings.musicOn=!settings.musicOn;
  saveAudioSettings();
  updateAudioButtons();
  toast(settings.musicOn?'Música ligada.':'Música desligada.');
}

function toggleSfx(){
  getAudioSettings();
  settings.sfxOn=!settings.sfxOn;
  saveAudioSettings();
  updateAudioButtons();
  toast(settings.sfxOn?'Efeitos sonoros ligados.':'Efeitos sonoros desligados.');
}

function playTone(freq,duration=.08,type='square',vol=.03){
  getAudioSettings();
  if(!settings.sfxOn) return;
  ensureAudio();
  if(audioCtx.state==='suspended') audioCtx.resume();
  const osc=audioCtx.createOscillator();
  const gain=audioCtx.createGain();
  osc.type=type;
  osc.frequency.value=freq;
  gain.gain.value=vol;
  osc.connect(gain);
  gain.connect(audioCtx.destination);
  osc.start();
  gain.gain.exponentialRampToValueAtTime(.0001,audioCtx.currentTime+duration);
  osc.stop(audioCtx.currentTime+duration);
}

function playSfx(kind){
  const map={
    click:[500,.04,'square',.02],
    success:[740,.08,'triangle',.03],
    coin:[980,.06,'triangle',.03],
    win:[660,.08,'square',.03],
    lose:[220,.10,'sawtooth',.02],
    levelup:[880,.12,'triangle',.04],
    buy:[560,.07,'square',.03],
    reward:[1046,.10,'triangle',.04]
  };
  const m=map[kind]||map.click;
  playTone(...m);
}

ensureStores();
initParticles();
renderAccentGrid();
renderWallpaperGrid();
applyTheme();
renderOfficials();
renderHome();
updateUserUI();
getAudioSettings();
updateAudioButtons();
<script src="script.js"></script>