<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ page import="java.sql.*" %>
<%
    Object tipoAttr=session.getAttribute("cli_tipo");
    boolean isCliente=(tipoAttr instanceof Integer)&&((Integer)tipoAttr)==2;
    String clienteNome=isCliente?(String)session.getAttribute("cli_nome"):null;
    String DB_URL="jdbc:mysql://localhost:3306/bd_pap?useSSL=false&serverTimezone=UTC",DB_USER="root",DB_PASS="";
    java.util.List<String[]> noticias=new java.util.ArrayList<>();
    Connection nc=null;try{Class.forName("com.mysql.cj.jdbc.Driver");nc=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS);ResultSet rn=nc.createStatement().executeQuery("SELECT titulo,conteudo,data_publicacao FROM t_noticia ORDER BY data_publicacao DESC");while(rn.next())noticias.add(new String[]{rn.getString("titulo"),rn.getString("conteudo"),rn.getString("data_publicacao")});rn.close();}catch(Exception ex){}finally{if(nc!=null)try{nc.close();}catch(Exception e){}}
%>
<!DOCTYPE html>
<html lang="pt">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Notícias — Hansa-Flex</title>
<link rel="stylesheet" href="css/shared.css">
<link rel="stylesheet" href="css/noticias.css">
</head>
<body>
<header>
  <div class="container header-inner">
    <a href="index.htm" class="logo">HANSA<em>-FLEX</em></a>
    <nav id="nav">
      <ul>
        <li><a href="index.htm">Início</a></li>
        <li><a href="produtos.jsp">Produtos</a></li>
        <li><a href="sobre.jsp">Sobre</a></li>
        <li><a href="noticias.jsp" class="active">Notícias</a></li>
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
    <div class="tag">Novidades</div>
    <h1>Notícias</h1>
    <p>Fique a par das últimas novidades da Hansa-Flex.</p>
  </div>
</div>

<div class="news-wrap">
  <div class="container">
    <% if(noticias.isEmpty()){ %>
      <div class="empty-box"><span>📰</span><h3>Sem notícias de momento.</h3><p>Volte em breve para novidades.</p></div>
    <% }else{ %>
    <div class="news-grid">
      <% for(String[] n:noticias){ %>
      <div class="news-card">
        <div class="news-date"><span class="news-dot"></span><%= n[2] %></div>
        <h3><%= n[0] %></h3>
        <p><%= n[1] %></p>
      </div>
      <% } %>
    </div>
    <% } %>
  </div>
</div>

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
