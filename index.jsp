<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ page import="java.sql.*" %>
<%
    Object tipoAttr=session.getAttribute("cli_tipo");
    boolean isCliente=(tipoAttr instanceof Integer)&&((Integer)tipoAttr)==2;
    String clienteNome=isCliente?(String)session.getAttribute("cli_nome"):null;
    String DB_URL="jdbc:mysql://localhost:3306/bd_pap?useSSL=false&serverTimezone=UTC",DB_USER="root",DB_PASS="";
    String msgContacto="";
    if("contacto".equals(request.getParameter("acao"))){
        String cN=request.getParameter("c_nome"),cE=request.getParameter("c_email"),cM=request.getParameter("c_mensagem");
        if(cN!=null&&!cN.trim().isEmpty()&&cE!=null&&!cE.trim().isEmpty()&&cM!=null&&!cM.trim().isEmpty()){
            Connection cc=null;try{Class.forName("com.mysql.cj.jdbc.Driver");cc=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS);int idc=1;PreparedStatement pf=cc.prepareStatement("SELECT id FROM t_cliente WHERE email=? LIMIT 1");pf.setString(1,cE);ResultSet rf=pf.executeQuery();if(rf.next())idc=rf.getInt("id");rf.close();pf.close();PreparedStatement pi=cc.prepareStatement("INSERT INTO t_solicitacao_de_contato(data,mensagem,status,id_cliente)VALUES(CURDATE(),?,'Pendente',?)");pi.setString(1,cM+" ["+cN+"|"+cE+"]");pi.setInt(2,idc);pi.executeUpdate();pi.close();msgContacto="ok";}catch(Exception ex){msgContacto="erro";}finally{if(cc!=null)try{cc.close();}catch(Exception e2){}}
        }
    }
    int totalProd=0;Connection pc=null;try{Class.forName("com.mysql.cj.jdbc.Driver");pc=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS);ResultSet rp=pc.createStatement().executeQuery("SELECT COUNT(*) FROM t_produto");if(rp.next())totalProd=rp.getInt(1);rp.close();}catch(Exception ex){}finally{if(pc!=null)try{pc.close();}catch(Exception e){}}
    java.util.List<String[]> noticias=new java.util.ArrayList<>();Connection nc=null;try{Class.forName("com.mysql.cj.jdbc.Driver");nc=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS);ResultSet rn=nc.createStatement().executeQuery("SELECT titulo,conteudo,data_publicacao FROM t_noticia ORDER BY data_publicacao DESC LIMIT 3");while(rn.next())noticias.add(new String[]{rn.getString("titulo"),rn.getString("conteudo"),rn.getString("data_publicacao")});rn.close();}catch(Exception ex){}finally{if(nc!=null)try{nc.close();}catch(Exception e){}}
%>
<!DOCTYPE html>
<html lang="pt">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Hansa-Flex — Sistemas Hidráulicos</title>
<link rel="stylesheet" href="css/shared.css">
<link rel="stylesheet" href="css/index.css">
</head>
<body>

<!-- ═══ HEADER ═══ -->
<header>
  <div class="container header-inner">
    <a href="index.htm" class="logo">HANSA<em>-FLEX</em></a>
    <nav id="nav">
      <ul>
        <li><a href="index.htm" class="active">Início</a></li>
        <li><a href="produtos.jsp">Produtos</a></li>
        <li><a href="sobre.jsp">Sobre</a></li>
        <li><a href="noticias.jsp">Notícias</a></li>
        <li class="nav-dropdown">
          <% if (isCliente) { %>
            <a href="#" class="dropdown-toggle">
              <span class="u-av"><%= clienteNome!=null?clienteNome.substring(0,1).toUpperCase():"U" %></span>
              <span style="color:var(--white);font-weight:600"><%= clienteNome!=null?clienteNome.split(" ")[0]:"Perfil" %></span>
              <span class="arrow">▾</span>
            </a>
            <ul class="dropdown-menu">
              <li><a href="perfil.jsp">👤 Minha Área</a></li>
              <li><a href="carinho.jsp">🛒 Carrinho</a></li>
              <li class="dd-div"></li>
              <li><a href="iniciarSessao.jsp?acao=logout">🚪 Sair</a></li>
            </ul>
          <% } else { %>
            <a href="iniciarSessao.jsp" class="btn-entrar">🔐 Entrar</a>
          <% } %>
        </li>
      </ul>
    </nav>
    <div class="header-right">
      <button class="btn-cart-icon" id="btnCart" title="Carrinho">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 3h1.386c.51 0 .955.343 1.087.835l.383 1.437M7.5 14.25a3 3 0 0 0-3 3h15.75m-12.75-3h11.218c1.121-2.3 2.1-4.684 2.924-7.138a60.114 60.114 0 0 0-16.536-1.84M7.5 14.25 5.106 5.272M6 20.25a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Zm12.75 0a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z"/></svg>
        <span class="cart-badge" id="cartBadge"></span>
      </button>
      <button class="menu-toggle" id="menuToggle">☰</button>
    </div>
  </div>
</header>

<div class="cart-overlay" id="cartOverlay"></div>
<div class="cart-panel" id="cartPanel">
  <div class="cart-head"><h3>🛒 Carrinho</h3><button class="cart-x" id="cartClose">×</button></div>
  <div class="cart-body" id="cartBody">
    <div class="cart-void" id="cartVoid">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 3h1.386c.51 0 .955.343 1.087.835l.383 1.437M7.5 14.25a3 3 0 0 0-3 3h15.75m-12.75-3h11.218c1.121-2.3 2.1-4.684 2.924-7.138a60.114 60.114 0 0 0-16.536-1.84M7.5 14.25 5.106 5.272M6 20.25a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Zm12.75 0a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z"/></svg>
      <p>O carrinho está vazio</p>
    </div>
  </div>
  <div class="cart-foot" id="cartFoot" style="display:none">
    <div class="cart-summ"><span id="cartQtyLabel">0 itens</span><strong id="cartTotalPrice">0,00 €</strong></div>
    <button class="btn-checkout-cart" onclick="irParaEncomenda()">Finalizar Pedido</button>
    <button class="btn-empty-cart" id="btnEsvaziar">Esvaziar carrinho</button>
  </div>
</div>

<!-- ═══ HERO ═══ -->
<section class="hero">
  <div class="hero-bg"></div>
  <div class="hero-grid-lines"></div>
  <div class="container">
    <div class="hero-content">
      <h1>Sistemas<em>Hidráulicos.</em></h1>
      <p>Componentes de qualidade certificada para a sua indústria. Entrega rápida em todo o território nacional, suporte técnico 24/7.</p>
      <div class="hero-btns">
        <a href="produtos.jsp" class="btn-primary">Ver Catálogo</a>
        <a href="#contato" class="btn-ghost">Falar com Técnico</a>
      </div>
    </div>
  </div>
</section>

<!-- ═══ SOBRE PREVIEW ═══ -->
<section class="sobre-section">
  <div class="container">
    <div class="sobre-grid">
      <div class="sobre-visual fade-up">
        <div class="sobre-img-box"><img src="images/empresa.png" alt="Hansa-Flex" style="width:100%;height:100%;object-fit:cover;border-radius:var(--r12);"></div>
        <div class="sobre-badge"><strong>1984</strong><span>Fundada em</span></div>
      </div>
      <div class="sobre-text fade-up">
        <div class="tag">Quem Somos</div>
        <h2 class="section-title">Mais de 40 anos em sistemas hidráulicos</h2>
        <p class="section-sub">Líder europeia em tecnologia hidráulica, presente em mais de 40 países. Em Portugal desde 1998, apoiando indústrias de todos os setores com componentes e serviço técnico especializado.</p>
        <div class="feature-list">
          <div class="feature-item"><div class="fi-icon">⚡</div><div class="fi-text"><strong>Resposta Rápida</strong><span>Entrega expressa em todo o território nacional</span></div></div>
          <div class="feature-item"><div class="fi-icon">🛠️</div><div class="fi-text"><strong>Suporte Técnico 24/7</strong><span>Equipa especializada sempre disponível</span></div></div>
          <div class="feature-item"><div class="fi-icon">✅</div><div class="fi-text"><strong>Qualidade Certificada</strong><span>Produtos certificados ISO 9001:2015</span></div></div>
        </div>
        <a href="sobre.jsp" style="display:inline-flex;align-items:center;gap:8px;margin-top:28px;padding:12px 22px;background:var(--navy);color:var(--white);border-radius:var(--r8);font-size:14px;font-weight:600;">Saber mais</a>
      </div>
    </div>
  </div>
</section>

<!-- ═══ NOTÍCIAS ═══ -->
<section class="news-section">
  <div class="container">
    <div class="tag">Novidades</div>
    <h2 class="section-title" style="color:var(--white)">Últimas Notícias</h2>
    <p class="section-sub" style="color:rgba(255,255,255,.5);margin-bottom:40px">Fique a par das novidades da Hansa-Flex.</p>
    <div class="news-grid">
      <% if(noticias.isEmpty()){ %>
        <p style="color:rgba(255,255,255,.3);font-size:14px">Sem notícias de momento.</p>
      <% }else{ for(String[] n:noticias){ %>
        <div class="news-card fade-up">
          <div class="news-date"><%= n[2] %></div>
          <h3><%= n[0] %></h3>
          <p><%= n[1]!=null&&n[1].length()>120?n[1].substring(0,120)+"…":n[1] %></p>
        </div>
      <% }} %>
    </div>
    <a href="noticias.jsp" class="ver-mais-btn">Ver todas as notícias</a>
  </div>
</section>

<!-- ═══ CONTACTO ═══ -->
<section class="contact-section" id="contato">
  <div class="container">
    <div class="contact-grid">
      <div class="contact-info fade-up">
        <div class="tag">Fale Connosco</div>
        <h2 class="section-title">Estamos aqui para ajudar</h2>
        <p class="section-sub">Dúvidas ou precisa de orçamento? A nossa equipa responde em menos de 24 horas.</p>
        <div class="contact-items">
          <div class="contact-item"><div class="ci-icon">📍</div><div class="ci-text"><strong>Sede</strong><span>Av. da Boavista, 1234 — Porto</span></div></div>
          <div class="contact-item"><div class="ci-icon">📞</div><div class="ci-text"><strong>Telefone</strong><span>+351 220 000 000</span></div></div>
          <div class="contact-item"><div class="ci-icon">📧</div><div class="ci-text"><strong>Email</strong><span>info@hansaflex.pt</span></div></div>
          <div class="contact-item"><div class="ci-icon">🕐</div><div class="ci-text"><strong>Horário</strong><span>Seg–Sex: 08h–18h</span></div></div>
        </div>
      </div>
      <div class="contact-form-box fade-up">
        <h3>Enviar Mensagem</h3>
        <div id="form-sucesso" style="display:none;text-align:center;padding:40px 20px;">
          <div style="font-size:48px;margin-bottom:16px;">✅</div>
          <h3 style="font-family:'Syne',sans-serif;font-size:20px;font-weight:800;color:var(--navy);margin-bottom:8px;">Mensagem enviada!</h3>
          <p style="color:var(--muted);font-size:14px;">Obrigado pelo contacto. Brevemente receberá uma resposta da nossa equipa.</p>
        </div>
        <form id="formContacto" onsubmit="enviarContacto(event)">
          <div class="form-group"><label>Nome *</label><input type="text" id="c_nome" placeholder="O seu nome" required></div>
          <div class="form-group"><label>Email *</label><input type="email" id="c_email" placeholder="email@exemplo.com" required></div>
          <div class="form-group"><label>Mensagem *</label><textarea id="c_mensagem" placeholder="A sua mensagem..." required></textarea></div>
          <div id="form-erro" style="display:none;" class="msg-err">⚠️ Erro ao enviar. Tente novamente.</div>
          <button type="submit" class="btn-submit" id="btnEnviar">Enviar Mensagem</button>
        </form>
      </div>
    </div>
  </div>
</section>

<footer><p>© 2026 <strong>Hansa-Flex</strong> — Todos os direitos reservados</p></footer>

<script>
document.getElementById('menuToggle').addEventListener('click',function(){document.getElementById('nav').classList.toggle('open');});
var cart=[];
var btnCart=document.getElementById('btnCart'),cartPanel=document.getElementById('cartPanel'),cartOverlay=document.getElementById('cartOverlay'),cartClose=document.getElementById('cartClose'),cartBadge=document.getElementById('cartBadge'),cartBody=document.getElementById('cartBody'),cartVoid=document.getElementById('cartVoid'),cartFoot=document.getElementById('cartFoot'),cartQtyLbl=document.getElementById('cartQtyLabel'),cartTotalP=document.getElementById('cartTotalPrice');
function openCart(){cartPanel.classList.add('open');cartOverlay.classList.add('open');document.body.style.overflow='hidden';}
function closeCart(){cartPanel.classList.remove('open');cartOverlay.classList.remove('open');document.body.style.overflow='';}
btnCart.addEventListener('click',openCart);cartClose.addEventListener('click',closeCart);cartOverlay.addEventListener('click',closeCart);
function saveCart(){try{localStorage.setItem('hf_carrinho',JSON.stringify(cart));}catch(e){}}
function loadCart(){try{var s=localStorage.getItem('hf_carrinho');cart=s?JSON.parse(s):[];}catch(e){cart=[];}}
function addToCart(id,nome,icon,preco){preco=parseFloat(preco);var ex=cart.find(function(i){return i.id===id;});if(ex){ex.qty++;}else{cart.push({id:id,nome:nome,icon:icon,preco:preco,qty:1});}saveCart();renderCart();openCart();}
function removeFromCart(id){cart=cart.filter(function(i){return i.id!==id;});saveCart();renderCart();}
function changeQty(id,delta){var item=cart.find(function(i){return i.id===id;});if(!item)return;item.qty+=delta;if(item.qty<=0)removeFromCart(id);else{saveCart();renderCart();}}
function renderCart(){var tq=cart.reduce(function(s,i){return s+i.qty;},0),tv=cart.reduce(function(s,i){return s+i.preco*i.qty;},0);cartBadge.textContent=tq>99?'99+':tq;tq>0?cartBadge.classList.add('show'):cartBadge.classList.remove('show');Array.from(cartBody.querySelectorAll('.cart-row')).forEach(function(el){el.remove();});cartVoid.style.display=cart.length===0?'flex':'none';cartFoot.style.display=cart.length===0?'none':'block';cartQtyLbl.textContent=tq+(tq===1?' item':' itens');cartTotalP.textContent=tv.toFixed(2).replace('.',',')+' €';cart.forEach(function(item){var d=document.createElement('div');d.className='cart-row';d.innerHTML='<div class="cart-thumb">'+(item.icon||'📦')+'</div><div class="cart-info"><h4>'+(item.nome||item.name||'Produto')+'</h4><p>'+(item.preco*item.qty).toFixed(2).replace('.',',')+' € ('+item.qty+' × '+item.preco.toFixed(2).replace('.',',')+' €)</p></div><div class="cart-qty"><button class="qbtn" onclick="changeQty('+item.id+',-1)">−</button><span class="qnum">'+item.qty+'</span><button class="qbtn" onclick="changeQty('+item.id+',1)">+</button></div><button class="cart-del" onclick="removeFromCart('+item.id+')">×</button>';cartBody.appendChild(d);});}
document.getElementById('btnEsvaziar').addEventListener('click',function(){cart=[];saveCart();renderCart();});
function irParaEncomenda(){if(cart.length===0)return;saveCart();window.location.href='carinho.jsp';}
loadCart();renderCart();
function enviarContacto(e){
  e.preventDefault();
  var nome=document.getElementById('c_nome').value.trim();
  var email=document.getElementById('c_email').value.trim();
  var msg=document.getElementById('c_mensagem').value.trim();
  if(!nome||!email||!msg)return;
  var btn=document.getElementById('btnEnviar');
  btn.textContent='A enviar...';btn.disabled=true;
  var fd=new FormData();
  fd.append('acao','contacto');fd.append('c_nome',nome);fd.append('c_email',email);fd.append('c_mensagem',msg);
  fetch('index.htm',{method:'POST',body:fd})
    .then(function(){
      document.getElementById('formContacto').style.display='none';
      var s=document.getElementById('form-sucesso');
      s.style.display='block';
      s.style.opacity='0';s.style.transform='translateY(20px)';s.style.transition='all .5s ease';
      setTimeout(function(){s.style.opacity='1';s.style.transform='translateY(0)';},50);
    })
    .catch(function(){
      document.getElementById('form-erro').style.display='block';
      btn.textContent='Enviar Mensagem';btn.disabled=false;
    });
}
var obs=new IntersectionObserver(function(entries){entries.forEach(function(e){if(e.isIntersecting)e.target.classList.add('visible');});},{threshold:0.15});
document.querySelectorAll('.fade-up').forEach(function(el){obs.observe(el);});
</script>
</body>
</html>
