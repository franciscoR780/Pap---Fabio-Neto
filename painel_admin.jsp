<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ page import="java.sql.*, java.io.*, java.text.SimpleDateFormat, java.util.Date" %>
<%
    /* ── PROTEÇÃO: só admins autenticados entram ── */
    Integer admId = (Integer) session.getAttribute("adm_id");
    if (admId == null) {
        response.sendRedirect("login_admin.jsp");
        return;
    }
    String adminNome = (String) session.getAttribute("adm_nome");
    if (adminNome == null) adminNome = "Admin";

    String DB_URL  = "jdbc:mysql://localhost:3306/bd_pap?useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "";

    /* ── BACKUP ── */
    String backupMsg = "";
    if ("backup".equals(request.getParameter("acao"))) {
        try {
            String dataHora = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String webRoot  = application.getRealPath("/");
            String outDir   = webRoot.replace("build\\web\\", "web\\")
                                     .replace("build/web/", "web/")
                                     .replaceAll("build[/\\\\]web[/\\\\]?$", "web/");
            if (!outDir.endsWith("/") && !outDir.endsWith("\\")) outDir += "/";
            outDir += "backups/";
            new File(outDir).mkdirs();
            String outFile = outDir + "bd_pap_" + dataHora + ".sql";

            String mysqldump = "C:\\xampp\\mysql\\bin\\mysqldump.exe";
            if (!new File(mysqldump).exists()) mysqldump = "mysqldump";

            ProcessBuilder pb = new ProcessBuilder(
                mysqldump, "-u", "root", "--single-transaction", "--skip-lock-tables", "bd_pap"
            );
            pb.redirectOutput(new File(outFile));
            pb.redirectErrorStream(false);
            final Process p = pb.start();
            p.waitFor();

            long size = new File(outFile).length();
            backupMsg = size > 100 ? "ok:backups/bd_pap_" + dataHora + ".sql" : "erro_vazio";
        } catch (Exception e) {
            backupMsg = "erro:" + e.getMessage();
        }
    }

    /* ── STATS DA BD ── */
    int nProdutos=0, nClientes=0, nPedidos=0, nContactos=0, nNoticias=0, nEncomendas=0;
    String ultimoPedido="-", ultimoContacto="-";
    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        ResultSet r;
        r = conn.createStatement().executeQuery("SELECT COUNT(*) FROM t_produto");       if(r.next()) nProdutos   = r.getInt(1); r.close();
        r = conn.createStatement().executeQuery("SELECT COUNT(*) FROM t_cliente");       if(r.next()) nClientes   = r.getInt(1); r.close();
        r = conn.createStatement().executeQuery("SELECT COUNT(*) FROM t_pedido");        if(r.next()) nPedidos    = r.getInt(1); r.close();
        r = conn.createStatement().executeQuery("SELECT COUNT(*) FROM t_solicitacao_de_contato"); if(r.next()) nContactos = r.getInt(1); r.close();
        r = conn.createStatement().executeQuery("SELECT COUNT(*) FROM t_noticia");       if(r.next()) nNoticias   = r.getInt(1); r.close();
        r = conn.createStatement().executeQuery("SELECT COUNT(*) FROM t_encomenda");     if(r.next()) nEncomendas = r.getInt(1); r.close();
        r = conn.createStatement().executeQuery("SELECT data FROM t_pedido ORDER BY id DESC LIMIT 1"); if(r.next()) ultimoPedido = r.getString(1); r.close();
        r = conn.createStatement().executeQuery("SELECT data FROM t_solicitacao_de_contato ORDER BY id DESC LIMIT 1"); if(r.next()) ultimoContacto = r.getString(1); r.close();
    } catch(Exception e) {
    } finally { if(conn!=null) try{conn.close();}catch(Exception e){} }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Painel Admin — Hansa-Flex</title>
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet">
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
:root{
  --navy:#0f2044;--blue2:#1e4d9b;--gold:#f0b429;--ink:#0b1220;
  --offwhite:#f7f8fa;--white:#fff;--muted:#677490;
  --border:#e2e8f0;--light:#edf1f7;
  --r8:8px;--r12:12px;--r20:20px;
  --shadow-sm:0 1px 3px rgba(11,18,32,.08);
  --shadow-md:0 4px 16px rgba(11,18,32,.12);
  --shadow-lg:0 12px 40px rgba(11,18,32,.16);
  --sidebar:260px;
}
body{font-family:'DM Sans',sans-serif;background:var(--offwhite);color:var(--ink);min-height:100vh;display:flex;}

/* ── SIDEBAR ── */
.sidebar{width:var(--sidebar);background:var(--navy);min-height:100vh;position:fixed;top:0;left:0;z-index:200;display:flex;flex-direction:column;padding:0;}
.sidebar-logo{padding:28px 24px 20px;border-bottom:1px solid rgba(255,255,255,.08);}
.sidebar-logo a{font-family:'Syne',sans-serif;font-size:20px;font-weight:800;color:var(--white);text-decoration:none;letter-spacing:1px;}
.sidebar-logo a em{color:var(--gold);font-style:normal;}
.sidebar-logo small{display:block;font-size:11px;color:rgba(255,255,255,.35);margin-top:2px;font-weight:500;letter-spacing:.5px;}
.sidebar-nav{flex:1;padding:16px 12px;overflow-y:auto;}
.nav-group{margin-bottom:24px;}
.nav-group-label{font-size:10px;font-weight:700;color:rgba(255,255,255,.3);letter-spacing:1.5px;text-transform:uppercase;padding:0 12px;margin-bottom:8px;}
.nav-item{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:var(--r8);color:rgba(255,255,255,.65);font-size:13px;font-weight:500;text-decoration:none;transition:all .2s;cursor:pointer;}
.nav-item:hover{background:rgba(255,255,255,.08);color:var(--white);}
.nav-item.active{background:rgba(240,180,41,.15);color:var(--gold);}
.nav-item .icon{width:18px;text-align:center;flex-shrink:0;}
.sidebar-footer{padding:16px 12px;border-top:1px solid rgba(255,255,255,.08);}
.admin-chip{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:var(--r8);background:rgba(255,255,255,.05);}
.admin-av{width:32px;height:32px;background:var(--gold);border-radius:50%;display:flex;align-items:center;justify-content:center;font-family:'Syne',sans-serif;font-size:14px;font-weight:800;color:var(--navy);flex-shrink:0;}
.admin-info strong{display:block;font-size:13px;font-weight:600;color:var(--white);}
.admin-info small{font-size:11px;color:rgba(255,255,255,.35);}
.btn-logout{display:flex;align-items:center;gap:8px;width:100%;margin-top:8px;padding:9px 12px;background:rgba(220,38,38,.12);border:1px solid rgba(220,38,38,.25);border-radius:var(--r8);color:#fca5a5;font-size:13px;font-weight:600;text-decoration:none;transition:all .2s;cursor:pointer;}
.btn-logout:hover{background:rgba(220,38,38,.2);}

/* ── MAIN ── */
.main{margin-left:var(--sidebar);flex:1;padding:32px 36px;min-height:100vh;}
.page-title{font-family:'Syne',sans-serif;font-size:24px;font-weight:800;color:var(--navy);margin-bottom:4px;}
.page-sub{font-size:14px;color:var(--muted);margin-bottom:32px;}

/* ── STATS GRID ── */
.stats-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:16px;margin-bottom:32px;}
.stat-card{background:var(--white);border:1px solid var(--border);border-radius:var(--r12);padding:20px;display:flex;flex-direction:column;gap:8px;box-shadow:var(--shadow-sm);transition:transform .2s,box-shadow .2s;}
.stat-card:hover{transform:translateY(-2px);box-shadow:var(--shadow-md);}
.stat-icon{font-size:24px;}
.stat-val{font-family:'Syne',sans-serif;font-size:28px;font-weight:800;color:var(--navy);}
.stat-label{font-size:12px;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;}

/* ── MÓDULOS GRID ── */
.section-title{font-family:'Syne',sans-serif;font-size:16px;font-weight:700;color:var(--navy);margin-bottom:16px;}
.modules-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:16px;margin-bottom:32px;}
.mod-card{background:var(--white);border:1px solid var(--border);border-radius:var(--r12);padding:22px;text-decoration:none;display:flex;flex-direction:column;gap:12px;box-shadow:var(--shadow-sm);transition:all .25s;}
.mod-card:hover{transform:translateY(-3px);box-shadow:var(--shadow-md);border-color:var(--blue2);}
.mod-icon{width:44px;height:44px;border-radius:var(--r8);display:flex;align-items:center;justify-content:center;font-size:20px;}
.mod-icon.blue{background:#eff6ff;} .mod-icon.green{background:#f0fdf4;} .mod-icon.amber{background:#fffbeb;}
.mod-icon.purple{background:#faf5ff;} .mod-icon.red{background:#fff1f2;} .mod-icon.teal{background:#f0fdfa;}
.mod-icon.indigo{background:#eef2ff;} .mod-icon.orange{background:#fff7ed;} .mod-icon.slate{background:#f8fafc;}
.mod-icon.cyan{background:#ecfeff;}
.mod-name{font-family:'Syne',sans-serif;font-size:14px;font-weight:700;color:var(--navy);}
.mod-desc{font-size:12px;color:var(--muted);}

/* ── BACKUP ── */
.backup-box{background:var(--white);border:1px solid var(--border);border-radius:var(--r12);padding:24px;box-shadow:var(--shadow-sm);margin-bottom:32px;}
.backup-row{display:flex;align-items:center;gap:16px;flex-wrap:wrap;}
.backup-info strong{display:block;font-size:14px;font-weight:700;color:var(--navy);margin-bottom:4px;}
.backup-info p{font-size:13px;color:var(--muted);}
.btn-backup{display:inline-flex;align-items:center;gap:8px;padding:11px 22px;background:var(--navy);color:var(--white);border:none;border-radius:var(--r8);font-size:13px;font-weight:700;cursor:pointer;text-decoration:none;font-family:'DM Sans',sans-serif;transition:background .2s;}
.btn-backup:hover{background:var(--blue2);}
.msg-ok{display:inline-flex;align-items:center;gap:8px;padding:10px 16px;background:#f0fdf4;border:1px solid #bbf7d0;border-radius:var(--r8);color:#15803d;font-size:13px;font-weight:600;}
.msg-err{display:inline-flex;align-items:center;gap:8px;padding:10px 16px;background:#fff1f2;border:1px solid #fecdd3;border-radius:var(--r8);color:#be123c;font-size:13px;font-weight:600;}

/* ── INFO ROW ── */
.info-row{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:32px;}
.info-card{background:var(--white);border:1px solid var(--border);border-radius:var(--r12);padding:20px;box-shadow:var(--shadow-sm);}
.info-card h4{font-family:'Syne',sans-serif;font-size:13px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;margin-bottom:12px;}
.info-item{display:flex;justify-content:space-between;align-items:center;padding:8px 0;border-bottom:1px solid var(--light);font-size:13px;}
.info-item:last-child{border-bottom:none;}
.info-item span{color:var(--muted);}
.info-item strong{color:var(--navy);}

@media(max-width:900px){
  .sidebar{transform:translateX(-100%);} .main{margin-left:0;padding:20px;}
  .info-row{grid-template-columns:1fr;}
}
</style>
</head>
<body>

<!-- ── SIDEBAR ── -->
<aside class="sidebar">
  <div class="sidebar-logo">
    <a href="../index.htm">HANSA<em>-FLEX</em></a>
    <small>PAINEL DE ADMINISTRAÇÃO</small>
  </div>

  <nav class="sidebar-nav">
    <div class="nav-group">
      <div class="nav-group-label">Geral</div>
      <a href="painel_admin.jsp" class="nav-item active"><span class="icon">🏠</span> Dashboard</a>
    </div>
    <div class="nav-group">
      <div class="nav-group-label">Catálogo</div>
      <a href="gerirProduto.jsp"    class="nav-item"><span class="icon">📦</span> Produtos</a>
      <a href="gerircatProduto.jsp" class="nav-item"><span class="icon">🗂️</span> Categorias</a>
    </div>
    <div class="nav-group">
      <div class="nav-group-label">Clientes & Pedidos</div>
      <a href="gerircliente.jsp"   class="nav-item"><span class="icon">👥</span> Clientes</a>
      <a href="gerirPedido.jsp"    class="nav-item"><span class="icon">🛒</span> Pedidos</a>
      <a href="gerirEncomenda.jsp" class="nav-item"><span class="icon">📬</span> Encomendas</a>
      <a href="gerirorcamento.jsp" class="nav-item"><span class="icon">📋</span> Orçamentos</a>
      <a href="gerircontato.jsp"   class="nav-item"><span class="icon">✉️</span> Contactos</a>
    </div>
    <div class="nav-group">
      <div class="nav-group-label">Conteúdo</div>
      <a href="gerirNoticia.jsp"       class="nav-item"><span class="icon">📰</span> Notícias</a>
      <a href="gerirUnidadeFilial.jsp" class="nav-item"><span class="icon">🏢</span> Filiais</a>
    </div>
    <div class="nav-group">
      <div class="nav-group-label">Sistema</div>
      <a href="gerirTipoUtilizador.jsp" class="nav-item"><span class="icon">🔑</span> Tipos de Utilizador</a>
      <a href="../index.htm" class="nav-item"><span class="icon">🌐</span> Ver Site</a>
    </div>
  </nav>

  <div class="sidebar-footer">
    <div class="admin-chip">
      <div class="admin-av"><%= adminNome.substring(0,1).toUpperCase() %></div>
      <div class="admin-info">
        <strong><%= adminNome %></strong>
        <small>Administrador</small>
      </div>
    </div>
    <a href="logout_admin.jsp" class="btn-logout">🚪 Terminar Sessão</a>
  </div>
</aside>

<!-- ── MAIN ── -->
<main class="main">
  <div class="page-title">Dashboard</div>
  <div class="page-sub">Bem-vindo, <%= adminNome %>. Aqui está o resumo do sistema.</div>

  <!-- STATS -->
  <div class="stats-grid">
    <div class="stat-card"><div class="stat-icon">📦</div><div class="stat-val"><%= nProdutos %></div><div class="stat-label">Produtos</div></div>
    <div class="stat-card"><div class="stat-icon">👥</div><div class="stat-val"><%= nClientes %></div><div class="stat-label">Clientes</div></div>
    <div class="stat-card"><div class="stat-icon">🛒</div><div class="stat-val"><%= nPedidos %></div><div class="stat-label">Pedidos</div></div>
    <div class="stat-card"><div class="stat-icon">📬</div><div class="stat-val"><%= nEncomendas %></div><div class="stat-label">Encomendas</div></div>
    <div class="stat-card"><div class="stat-icon">✉️</div><div class="stat-val"><%= nContactos %></div><div class="stat-label">Contactos</div></div>
    <div class="stat-card"><div class="stat-icon">📰</div><div class="stat-val"><%= nNoticias %></div><div class="stat-label">Notícias</div></div>
  </div>

  <!-- INFO ROW -->
  <div class="info-row">
    <div class="info-card">
      <h4>Atividade Recente</h4>
      <div class="info-item"><span>Último pedido</span><strong><%= ultimoPedido %></strong></div>
      <div class="info-item"><span>Último contacto</span><strong><%= ultimoContacto %></strong></div>
      <div class="info-item"><span>Total encomendas</span><strong><%= nEncomendas %></strong></div>
      <div class="info-item"><span>Total pedidos</span><strong><%= nPedidos %></strong></div>
    </div>
    <div class="info-card">
      <h4>Estado da BD</h4>
      <div class="info-item"><span>Base de dados</span><strong>bd_pap</strong></div>
      <div class="info-item"><span>Servidor</span><strong>localhost:3306</strong></div>
      <div class="info-item"><span>Estado</span><strong style="color:#15803d"><%= nProdutos >= 0 ? "✅ Online" : "❌ Offline" %></strong></div>
      <div class="info-item"><span>Tabelas</span><strong>13</strong></div>
    </div>
  </div>

  <!-- BACKUP -->
  <div class="section-title">💾 Backup da Base de Dados</div>
  <div class="backup-box">
    <div class="backup-row">
      <div class="backup-info">
        <strong>Exportar bd_pap</strong>
        <p>Gera um ficheiro .sql na pasta <code>backups/</code> dentro do projeto web.</p>
      </div>
      <form method="post" action="painel_admin.jsp" style="margin:0">
        <input type="hidden" name="acao" value="backup">
        <button type="submit" class="btn-backup">💾 Fazer Backup Agora</button>
      </form>
      <%
        if (backupMsg.startsWith("ok:")) {
          String ficheiro = backupMsg.substring(3);
      %>
        <div class="msg-ok">✅ Backup guardado em <strong><%= ficheiro %></strong></div>
      <% } else if ("erro_vazio".equals(backupMsg)) { %>
        <div class="msg-err">⚠️ Ficheiro vazio. Verifique se o mysqldump está em <code>C:\xampp\mysql\bin\</code></div>
      <% } else if (backupMsg.startsWith("erro")) { %>
        <div class="msg-err">⚠️ Erro: <%= backupMsg.contains(":") ? backupMsg.substring(backupMsg.indexOf(":")+1) : "verifique o servidor" %></div>
      <% } %>
    </div>
  </div>

  <!-- MÓDULOS -->
  <div class="section-title">⚙️ Módulos de Gestão</div>
  <div class="modules-grid">
    <a href="gerirProduto.jsp" class="mod-card">
      <div class="mod-icon blue">📦</div>
      <div class="mod-name">Produtos</div>
      <div class="mod-desc">Adicionar, editar e remover produtos do catálogo</div>
    </a>
    <a href="gerircatProduto.jsp" class="mod-card">
      <div class="mod-icon slate">🗂️</div>
      <div class="mod-name">Categorias</div>
      <div class="mod-desc">Gerir categorias de produtos</div>
    </a>
    <a href="gerircliente.jsp" class="mod-card">
      <div class="mod-icon green">👥</div>
      <div class="mod-name">Clientes</div>
      <div class="mod-desc">Consultar e administrar clientes registados</div>
    </a>
    <a href="gerirPedido.jsp" class="mod-card">
      <div class="mod-icon amber">🛒</div>
      <div class="mod-name">Pedidos</div>
      <div class="mod-desc">Gerir e acompanhar pedidos dos clientes</div>
    </a>
    <a href="gerirEncomenda.jsp" class="mod-card">
      <div class="mod-icon cyan">📬</div>
      <div class="mod-name">Encomendas</div>
      <div class="mod-desc">Gerir encomendas submetidas pelos clientes</div>
    </a>
    <a href="gerirorcamento.jsp" class="mod-card">
      <div class="mod-icon purple">📋</div>
      <div class="mod-name">Orçamentos</div>
      <div class="mod-desc">Consultar e responder a pedidos de orçamento</div>
    </a>
    <a href="gerircontato.jsp" class="mod-card">
      <div class="mod-icon teal">✉️</div>
      <div class="mod-name">Contactos</div>
      <div class="mod-desc">Ver mensagens enviadas pelo formulário de contacto</div>
    </a>
    <a href="gerirNoticia.jsp" class="mod-card">
      <div class="mod-icon indigo">📰</div>
      <div class="mod-name">Notícias</div>
      <div class="mod-desc">Publicar e gerir notícias do site</div>
    </a>
    <a href="gerirUnidadeFilial.jsp" class="mod-card">
      <div class="mod-icon orange">🏢</div>
      <div class="mod-name">Filiais</div>
      <div class="mod-desc">Gerir unidades e filiais da empresa</div>
    </a>
    <a href="gerirTipoUtilizador.jsp" class="mod-card">
      <div class="mod-icon slate">🔑</div>
      <div class="mod-name">Tipos de Utilizador</div>
      <div class="mod-desc">Gerir os tipos de perfil de acesso</div>
    </a>
  </div>

</main>
</body>
</html>
