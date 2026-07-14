<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ page import="java.sql.*" %>
<%
    Object tipoAttr=session.getAttribute("cli_tipo");
    boolean isCliente=(tipoAttr instanceof Integer)&&((Integer)tipoAttr)==2;
    String clienteNome=isCliente?(String)session.getAttribute("cli_nome"):null;
    String clienteEmail=isCliente?(String)session.getAttribute("cli_email"):null;
    String clienteTel=isCliente?(String)session.getAttribute("cli_telefone"):null;
    String msgFinal="";
    String acao=request.getParameter("acao");
    if("finalizar".equals(acao)&&isCliente){
        String DB_URL="jdbc:mysql://localhost:3306/bd_pap?useSSL=false&serverTimezone=UTC",DB_USER="root",DB_PASS="";
        try{Class.forName("com.mysql.cj.jdbc.Driver");Connection conn=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS);
        String[] produtos=request.getParameterValues("prod_nome"),quantidades=request.getParameterValues("prod_qtd"),prodIds=request.getParameterValues("prod_id");
        String morada=request.getParameter("morada"),localidade=request.getParameter("localidade"),codPostal=request.getParameter("cod_postal"),obs=request.getParameter("obs");
        if(produtos!=null){for(int i=0;i<produtos.length;i++){int prodId=0;try{prodId=Integer.parseInt(prodIds[i]);}catch(Exception ex){prodId=0;}
        if(prodId<=0){PreparedStatement psBusca=conn.prepareStatement("SELECT id FROM t_produto WHERE descricao LIKE ? LIMIT 1");psBusca.setString(1,"%"+produtos[i]+"%");ResultSet rsBusca=psBusca.executeQuery();if(rsBusca.next())prodId=rsBusca.getInt("id");else prodId=1;rsBusca.close();psBusca.close();}
        int qtd=1;try{qtd=Integer.parseInt(quantidades[i]);}catch(Exception ex){}
        PreparedStatement ps=conn.prepareStatement("INSERT INTO t_encomenda (produto_id,nome_cliente,email_cliente,telefone,morada,localidade,codigo_postal,pais,quantidade,observacoes,estado) VALUES (?,?,?,?,?,?,?,'Portugal',?,?,?)");
        ps.setInt(1,prodId);ps.setString(2,clienteNome!=null?clienteNome:"");ps.setString(3,clienteEmail!=null?clienteEmail:"");ps.setString(4,clienteTel!=null?clienteTel:"");ps.setString(5,morada!=null?morada:"");ps.setString(6,localidade!=null?localidade:"");ps.setString(7,codPostal!=null?codPostal:"");ps.setInt(8,qtd);ps.setString(9,obs!=null?obs:"");ps.setString(10,"Pendente");
        ps.executeUpdate();ps.close();}msgFinal="ok";}conn.close();
        }catch(Exception e){msgFinal="erro:"+e.getMessage();}
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Carrinho — Hansa-Flex</title>
<link rel="stylesheet" href="css/shared.css">
<link rel="stylesheet" href="css/carinho.css">
</head>
<body>

<header class="cart-page-header">
  <div class="header-inner">
    <a href="index.htm" class="logo">HANSA<em>-FLEX</em></a>
    <div style="display:flex;gap:8px">
      <a href="produtos.jsp" class="btn-nav">Produtos</a>
      <% if(isCliente){ %>
        <a href="perfil.jsp" class="btn-nav btn-nav-gold">👤 Minha Área</a>
        <a href="iniciarSessao.jsp?acao=logout" class="btn-nav">🚪 Sair</a>
      <% }else{ %>
        <a href="iniciarSessao.jsp" class="btn-nav btn-nav-gold">🔐 Entrar</a>
      <% } %>
    </div>
  </div>
</header>

<div class="main">
  <div class="breadcrumb"><a href="index.htm">Início</a> › <strong>Carrinho</strong></div>
  <div class="page-title">🛒 Meu Carrinho <span class="badge-count" id="badgeTotalItens">0 itens</span></div>
  <% if(!isCliente){ %>
  <div class="aviso-login">ℹ️ <span>Para finalizar a encomenda precisa de estar autenticado. <a href="iniciarSessao.jsp">Iniciar sessão</a> ou <a href="iniciarSessao.jsp">criar conta grátis</a>.</span></div>
  <% } %>
  <% if("ok".equals(msgFinal)){ %>
  <div class="success-box"><span class="sicon">✅</span><h3>Encomenda registada com sucesso!</h3><p>Em breve entraremos em contacto. <a href="perfil.jsp" style="color:var(--blue2);font-weight:700;">Ver as minhas encomendas →</a></p></div>
  <% } %>
  <div class="cart-layout">
    <div>
      <div class="cart-table">
        <div class="cart-table-head"><span>Produto</span><span style="text-align:center">Quantidade</span><span style="text-align:right">Subtotal</span><span></span></div>
        <div id="cartItensContainer">
          <div class="cart-empty-state" id="estadoVazio"><span class="icon">🛒</span><h3>Carrinho vazio</h3><p>Adicione produtos a partir da <a href="produtos.jsp" style="color:var(--blue2);font-weight:700;">página de produtos</a>.</p></div>
        </div>
        <div class="cart-footer-bar" id="listaFooter" style="display:none">
          <button class="btn-clear" onclick="limparCarrinho()">🗑 Limpar tudo</button>
          <a href="produtos.jsp" class="btn-continue">Continuar a comprar</a>
        </div>
      </div>
    </div>
    <div>
      <div class="resumo">
        <div class="resumo-head">🧾 Resumo do Pedido</div>
        <div class="resumo-body">
          <div class="resumo-row"><span class="label">Produtos</span><span class="val" id="resumoProdutos">0</span></div>
          <div class="resumo-row"><span class="label">Unidades</span><span class="val" id="resumoUnidades">0</span></div>
          <div class="resumo-row"><span class="label">Subtotal</span><span class="val" id="resumoSubtotal">0,00 €</span></div>
          <div class="resumo-row"><span class="label">Entrega</span><span style="color:var(--verde);font-weight:600;font-size:13px;">A calcular</span></div>
        </div>
        <div style="padding:0 24px 4px"><div class="resumo-total"><span class="rt-label">Total estimado</span><span class="rt-value" id="resumoTotal">0,00 €</span></div></div>
        <div class="resumo-actions"><button class="btn-finalizar" id="btnFinalizar" onclick="abrirModal()" disabled>✅ Finalizar Encomenda</button></div>
        <div class="resumo-sec">🔒 Transação segura · Dados protegidos</div>
      </div>
    </div>
  </div>
</div>

<div class="modal-overlay" id="modalOverlay">
  <div class="modal">
    <div class="modal-head"><h3>📋 Dados de Entrega</h3><button class="modal-close" onclick="fecharModal()">×</button></div>
    <div class="modal-body">
      <div class="campo"><label>Morada *</label><input type="text" id="m-morada" placeholder="Rua e número" required></div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
        <div class="campo"><label>Localidade *</label><input type="text" id="m-localidade" placeholder="Cidade" required></div>
        <div class="campo"><label>Código Postal *</label><input type="text" id="m-cp" placeholder="0000-000" required></div>
      </div>
      <div class="campo"><label>Observações</label><textarea id="m-obs" placeholder="Notas de entrega..."></textarea></div>
      <div class="modal-erro" id="modalErro"></div>
    </div>
    <div class="modal-foot">
      <button class="btn-modal-ok" onclick="submeterEncomenda()">✅ Confirmar Encomenda</button>
      <button class="btn-modal-cancel" onclick="fecharModal()">Cancelar</button>
    </div>
  </div>
</div>
<div class="toast" id="toast"></div>

<script>
var carrinho=[];
function carregarCarrinho(){try{var s=localStorage.getItem('hf_carrinho');carrinho=s?JSON.parse(s):[];}catch(e){carrinho=[];}}
function guardarCarrinho(){try{localStorage.setItem('hf_carrinho',JSON.stringify(carrinho));}catch(e){}}
function removerItem(id){carrinho=carrinho.filter(function(x){return x.id!=id;});guardarCarrinho();renderizar();mostrarToast('🗑 Removido');}
function alterarQtd(id,delta){var item=carrinho.find(function(x){return x.id==id;});if(!item)return;item.qty+=delta;if(item.qty<=0){carrinho=carrinho.filter(function(x){return x.id!=id;});mostrarToast('🗑 Removido');}guardarCarrinho();renderizar();}
function limparCarrinho(){carrinho=[];guardarCarrinho();renderizar();mostrarToast('🗑 Carrinho limpo');}
function renderizar(){
  var container=document.getElementById('cartItensContainer'),footer=document.getElementById('listaFooter'),vazio=document.getElementById('estadoVazio');
  if(carrinho.length===0){container.innerHTML='';container.appendChild(vazio);vazio.style.display='block';footer.style.display='none';atualizarResumo();return;}
  vazio.style.display='none';footer.style.display='flex';
  var html='';
  for(var i=0;i<carrinho.length;i++){var item=carrinho[i],nome=item.name||item.nome||'Produto',preco=item.preco||0,qtd=item.qty||1,icone=item.icon||'📦',sub=(preco*qtd).toFixed(2),itemId=item.id||0;
  html+='<div class="cart-item"><div class="item-info"><div class="item-icon">'+icone+'</div><div><div class="item-name">'+nome+'</div><div class="item-unit">'+preco.toFixed(2)+' € / un.</div></div></div><div class="item-qty"><button class="qty-btn" onclick="alterarQtd('+itemId+',-1)">−</button><span class="qty-num">'+qtd+'</span><button class="qty-btn" onclick="alterarQtd('+itemId+',1)">+</button></div><div class="item-subtotal">'+sub+' €</div><div><button class="btn-remove" onclick="removerItem('+itemId+')" title="Remover">✕</button></div></div>';}
  container.innerHTML=html;atualizarResumo();
}
function atualizarResumo(){var tq=0,tp=0;for(var i=0;i<carrinho.length;i++){tq+=carrinho[i].qty||1;tp+=(carrinho[i].preco||0)*(carrinho[i].qty||1);}var n=carrinho.length,tem=n>0;
document.getElementById('badgeTotalItens').textContent=tq+(tq===1?' item':' itens');document.getElementById('resumoProdutos').textContent=n+(n===1?' produto':' produtos');document.getElementById('resumoUnidades').textContent=tq+' un.';document.getElementById('resumoSubtotal').textContent=tp.toFixed(2).replace('.',',')+' €';document.getElementById('resumoTotal').textContent=tp.toFixed(2).replace('.',',')+' €';document.getElementById('btnFinalizar').disabled=!tem;}
function abrirModal(){if(carrinho.length===0)return;<% if(!isCliente){ %>window.location.href='iniciarSessao.jsp';return;<% } %>document.getElementById('modalOverlay').classList.add('aberto');document.body.style.overflow='hidden';}
function fecharModal(){document.getElementById('modalOverlay').classList.remove('aberto');document.body.style.overflow='';}
document.getElementById('modalOverlay').addEventListener('click',function(e){if(e.target===this)fecharModal();});
function submeterEncomenda(){var morada=document.getElementById('m-morada').value.trim(),localidade=document.getElementById('m-localidade').value.trim(),cp=document.getElementById('m-cp').value.trim(),erroEl=document.getElementById('modalErro');if(!morada||!localidade||!cp){erroEl.textContent='⚠️ Preencha os campos obrigatórios.';erroEl.style.display='block';return;}erroEl.style.display='none';
var form=document.createElement('form');form.method='post';form.action='carinho.jsp';function addField(n,v){var inp=document.createElement('input');inp.type='hidden';inp.name=n;inp.value=v;form.appendChild(inp);}
addField('acao','finalizar');addField('morada',morada);addField('localidade',localidade);addField('cod_postal',cp);addField('obs',document.getElementById('m-obs').value);
for(var i=0;i<carrinho.length;i++){var item=carrinho[i];addField('prod_nome',item.name||item.nome||'Produto');addField('prod_qtd',item.qty||1);addField('prod_id',item.id||0);}
document.body.appendChild(form);localStorage.removeItem('hf_carrinho');form.submit();}
function mostrarToast(msg){var t=document.getElementById('toast');t.textContent=msg;t.classList.add('visivel');setTimeout(function(){t.classList.remove('visivel');},3000);}
carregarCarrinho();renderizar();
</script>
</body>
</html>
