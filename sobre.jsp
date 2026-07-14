<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ page import="java.sql.*" %>
<%
    Object tipoAttr=session.getAttribute("cli_tipo");
    boolean isCliente=(tipoAttr instanceof Integer)&&((Integer)tipoAttr)==2;
    String clienteNome=isCliente?(String)session.getAttribute("cli_nome"):null;

    String DB_URL="jdbc:mysql://localhost:3306/bd_pap?useSSL=false&serverTimezone=UTC",DB_USER="root",DB_PASS="";
    java.util.List<String[]> filiais = new java.util.ArrayList<>();
    Connection fc = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        fc = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        ResultSet rf = fc.createStatement().executeQuery(
            "SELECT nome, cidade, telefone FROM t_unidade_filial ORDER BY cidade");
        while (rf.next()) {
            filiais.add(new String[]{
                rf.getString("nome"),
                rf.getString("cidade"),
                rf.getString("telefone")
            });
        }
        rf.close();
    } catch(Exception ex) {
    } finally {
        if (fc != null) try { fc.close(); } catch(Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Sobre Nós — Hansa-Flex</title>
<link rel="stylesheet" href="css/shared.css">
<link rel="stylesheet" href="css/sobre.css">
</head>
<body>
<header>
  <div class="container header-inner">
    <a href="index.htm" class="logo">HANSA<em>-FLEX</em></a>
    <nav id="nav">
      <ul>
        <li><a href="index.htm">Início</a></li>
        <li><a href="produtos.jsp">Produtos</a></li>
        <li><a href="sobre.jsp" class="active">Sobre</a></li>
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
      <button class="btn-cart-icon" id="btnCart">
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
  <div class="cart-body" id="cartBody"><div class="cart-void" id="cartVoid"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 3h1.386c.51 0 .955.343 1.087.835l.383 1.437M7.5 14.25a3 3 0 0 0-3 3h15.75m-12.75-3h11.218c1.121-2.3 2.1-4.684 2.924-7.138a60.114 60.114 0 0 0-16.536-1.84M7.5 14.25 5.106 5.272M6 20.25a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Zm12.75 0a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z"/></svg><p>O carrinho está vazio</p></div></div>
  <div class="cart-foot" id="cartFoot" style="display:none"><div class="cart-summ"><span id="cartQtyLabel">0 itens</span><strong id="cartTotalPrice">0,00 €</strong></div><button class="btn-checkout-cart" onclick="irParaEncomenda()">Finalizar Pedido</button><button class="btn-empty-cart" id="btnEsvaziar">Esvaziar carrinho</button></div>
</div>

<div class="page-header">
  <div class="container page-header-inner">
    <div class="tag">Quem Somos</div>
    <h1>Sobre a Hansa-Flex</h1>
    <p>Líder europeia em tecnologia hidráulica há mais de 40 anos.</p>
  </div>
</div>

<section class="sobre-section">
  <div class="container">
    <div class="sobre-grid">
      <div style="position:relative;">
        <div class="sobre-img-box"><img src="images/hansaflex.png" alt="Hansa-Flex" style="width:100%;height:100%;object-fit:cover;border-radius:var(--r12);"></div>
        <div class="sobre-badge"><strong>1984</strong><span>Fundada em</span></div>
      </div>
      <div class="sobre-text">
        <div class="tag">A Nossa História</div>
        <h2 class="section-title">Mais de 40 anos em sistemas hidráulicos</h2>
        <p>A Hansa-Flex é líder europeia em tecnologia hidráulica, com presença em mais de 40 países e milhões de produtos entregues anualmente a clientes industriais em todo o mundo.</p>
        <p>Em Portugal, estamos presentes desde 1998, apoiando indústrias dos mais variados setores com componentes de qualidade certificada e serviço técnico especializado.</p>
        <div class="feature-list">
          <div class="fi"><div class="fi-icon">⚡</div><div class="fi-text"><strong>Resposta Rápida</strong><span>Entrega expressa em todo o território nacional</span></div></div>
          <div class="fi"><div class="fi-icon">🛠️</div><div class="fi-text"><strong>Suporte Técnico 24/7</strong><span>Equipa especializada sempre disponível</span></div></div>
          <div class="fi"><div class="fi-icon">✅</div><div class="fi-text"><strong>Qualidade Certificada</strong><span>Produtos certificados ISO 9001:2015</span></div></div>
        </div>
      </div>
    </div>

    <div class="stats-band">
      <div class="stat-box"><strong>+40</strong><span>Anos de experiência</span></div>
      <div class="stat-box"><strong>40+</strong><span>Países no mundo</span></div>
      <div class="stat-box"><strong><%= filiais.isEmpty() ? "4" : filiais.size() %></strong><span>Filiais em Portugal</span></div>
      <div class="stat-box"><strong>24/7</strong><span>Suporte técnico</span></div>
    </div>

    <div class="tag">As Nossas Filiais</div>
    <h2 class="section-title" style="margin-bottom:28px">Presentes em todo o país</h2>
    <div class="filiais-grid">
      <% if (filiais.isEmpty()) { %>
        <p style="color:#888;font-size:14px">Sem filiais registadas de momento.</p>
      <% } else {
           for (String[] f : filiais) {
               String nome     = f[0] != null ? f[0] : "";
               String cidade   = f[1] != null ? f[1] : "";
               String telefone = f[2] != null ? f[2] : "";
      %>
      <div class="filial-card">
        <h3>📍 <%= cidade %></h3>
        <p><%= nome %><br>+351 <%= telefone %></p>
      </div>
      <% } } %>
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
function removeFromCart(id){cart=cart.filter(function(i){return i.id!==id;});saveCart();renderCart();}
function changeQty(id,delta){var item=cart.find(function(i){return i.id===id;});if(!item)return;item.qty+=delta;if(item.qty<=0)removeFromCart(id);else{saveCart();renderCart();}}
function renderCart(){var tq=cart.reduce(function(s,i){return s+i.qty;},0),tv=cart.reduce(function(s,i){return s+i.preco*i.qty;},0);cartBadge.textContent=tq>99?'99+':tq;tq>0?cartBadge.classList.add('show'):cartBadge.classList.remove('show');Array.from(cartBody.querySelectorAll('.cart-row')).forEach(function(el){el.remove();});cartVoid.style.display=cart.length===0?'flex':'none';cartFoot.style.display=cart.length===0?'none':'block';cartQtyLbl.textContent=tq+(tq===1?' item':' itens');cartTotalP.textContent=tv.toFixed(2).replace('.',',')+' €';cart.forEach(function(item){var d=document.createElement('div');d.className='cart-row';d.innerHTML='<div class="cart-thumb">'+(item.icon||'📦')+'</div><div class="cart-info"><h4>'+(item.nome||item.name||'Produto')+'</h4><p>'+(item.preco*item.qty).toFixed(2).replace('.',',')+' € ('+item.qty+' × '+item.preco.toFixed(2).replace('.',',')+' €)</p></div><div class="cart-qty"><button class="qbtn" onclick="changeQty('+item.id+',-1)">−</button><span class="qnum">'+item.qty+'</span><button class="qbtn" onclick="changeQty('+item.id+',1)">+</button></div><button class="cart-del" onclick="removeFromCart('+item.id+')">×</button>';cartBody.appendChild(d);});}
document.getElementById('btnEsvaziar').addEventListener('click',function(){cart=[];saveCart();renderCart();});
function irParaEncomenda(){if(cart.length===0)return;saveCart();window.location.href='carinho.jsp';}
loadCart();renderCart();
</script>
</body>
</html>
