<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ page import="java.sql.*, java.security.MessageDigest, java.nio.charset.StandardCharsets" %>
<%!
    /* ── Utilitário SHA-256 disponível em toda a página ── */
    private String sha256(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) { return ""; }
    }
%>
<%
    String dbUrl="jdbc:mysql://localhost:3306/bd_pap?useSSL=false&serverTimezone=UTC",dbUser="root",dbPass="";
    String acao=request.getParameter("acao"), msgErro="";

    /* ── LOGOUT do cliente ── */
    if("logout".equals(acao)){
        session.removeAttribute("cli_id");
        session.removeAttribute("cli_nome");
        session.removeAttribute("cli_email");
        session.removeAttribute("cli_telefone");
        session.removeAttribute("cli_usuario");
        session.removeAttribute("cli_tipo");
        response.sendRedirect("index.htm");
        return;
    }

    /* ── LOGIN ── */
    if("login".equals(acao)){
        String nu=request.getParameter("nome_de_usario"),pp=request.getParameter("palavra_passe");
        if(nu==null||nu.trim().isEmpty()||pp==null||pp.trim().isEmpty()){
            msgErro="Preencha todos os campos.";
        } else {
            String ppHash = sha256(pp.trim());
            try{
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn=DriverManager.getConnection(dbUrl,dbUser,dbPass);
                PreparedStatement psC=conn.prepareStatement(
                    "SELECT id,nome,email,telefone FROM t_cliente WHERE nome_de_usario=? AND palavra_passe=?");
                psC.setString(1,nu.trim()); psC.setString(2,ppHash);
                ResultSet rsC=psC.executeQuery();
                if(rsC.next()){
                    session.setAttribute("cli_id",       rsC.getInt("id"));
                    session.setAttribute("cli_nome",     rsC.getString("nome"));
                    session.setAttribute("cli_email",    rsC.getString("email"));
                    session.setAttribute("cli_telefone", rsC.getString("telefone"));
                    session.setAttribute("cli_usuario",  nu.trim());
                    session.setAttribute("cli_tipo",     2);
                    rsC.close(); psC.close(); conn.close();
                    response.sendRedirect("index.htm");
                    return;
                }
                rsC.close(); psC.close(); conn.close();
                msgErro="Nome de utilizador ou palavra-passe incorretos.";
            }catch(Exception e){ msgErro="Erro de ligação: "+e.getMessage(); }
        }
    }

    /* ── REGISTO ── */
    if("registar".equals(acao)){
        String nome=request.getParameter("nome"),email=request.getParameter("email"),
               tel=request.getParameter("telefone"),nu=request.getParameter("nome_de_usario"),
               pp=request.getParameter("palavra_passe"),
               pergunta=request.getParameter("pergunta_seguranca"),
               resposta=request.getParameter("resposta_seguranca");
        if(nome==null||nome.trim().isEmpty()||email==null||email.trim().isEmpty()||
           tel==null||tel.trim().isEmpty()||nu==null||nu.trim().isEmpty()||pp==null||pp.trim().isEmpty()||
           pergunta==null||pergunta.isEmpty()||resposta==null||resposta.trim().isEmpty()){
            msgErro="Preencha todos os campos obrigatórios.";
        } else {
            String ppHash = sha256(pp.trim());
            try{
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn=DriverManager.getConnection(dbUrl,dbUser,dbPass);
                /* Verificar utilizador duplicado */
                PreparedStatement ck=conn.prepareStatement("SELECT id FROM t_cliente WHERE nome_de_usario=?");
                ck.setString(1,nu.trim()); ResultSet rck=ck.executeQuery();
                if(rck.next()){ msgErro="Nome de utilizador já existe."; rck.close(); ck.close(); conn.close(); }
                else{
                    rck.close(); ck.close();
                    /* Verificar email duplicado */
                    PreparedStatement ce=conn.prepareStatement("SELECT id FROM t_cliente WHERE email=?");
                    ce.setString(1,email.trim()); ResultSet rce=ce.executeQuery();
                    if(rce.next()){ msgErro="Email já registado."; rce.close(); ce.close(); conn.close(); }
                    else{
                        rce.close(); ce.close();
                        /* Inserir novo cliente com pergunta e resposta de segurança */
                        PreparedStatement ins=conn.prepareStatement(
                            "INSERT INTO t_cliente(nome,email,telefone,endereco,nome_de_usario,palavra_passe,id_tipo_utilizador,pergunta_seguranca,resposta_seguranca) VALUES(?,?,?,?,?,?,2,?,?)");
                        ins.setString(1,nome.trim()); ins.setString(2,email.trim()); ins.setString(3,tel.trim());
                        ins.setString(4,""); ins.setString(5,nu.trim()); ins.setString(6,ppHash);
                        ins.setString(7,pergunta.trim()); ins.setString(8,resposta.trim());
                        ins.executeUpdate(); ins.close();
                        /* Login automático após registo */
                        PreparedStatement pl=conn.prepareStatement(
                            "SELECT id,nome,email,telefone FROM t_cliente WHERE nome_de_usario=? AND palavra_passe=?");
                        pl.setString(1,nu.trim()); pl.setString(2,ppHash); ResultSet rl=pl.executeQuery();
                        if(rl.next()){
                            session.setAttribute("cli_id",       rl.getInt("id"));
                            session.setAttribute("cli_nome",     rl.getString("nome"));
                            session.setAttribute("cli_email",    rl.getString("email"));
                            session.setAttribute("cli_telefone", rl.getString("telefone"));
                            session.setAttribute("cli_usuario",  nu.trim());
                            session.setAttribute("cli_tipo",     2);
                        }
                        rl.close(); pl.close(); conn.close();
                        response.sendRedirect("index.htm");
                        return;
                    }
                }
            }catch(Exception e){ msgErro="Erro de ligação: "+e.getMessage(); }
        }
    }

    String msgErroFinal=msgErro;
%>
<!DOCTYPE html>
<html lang="pt">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Iniciar Sessão — Hansa-Flex</title>
<link rel="stylesheet" href="css/shared.css">
<link rel="stylesheet" href="css/iniciarSessao.css">
</head>
<body>
<div class="page">
  <div class="panel-left">
    <div class="pl-content">
      <div class="pl-logo">HANSA<em>-FLEX</em></div>
      <h1 class="pl-title">A sua plataforma<em>industrial online.</em></h1>
      <p class="pl-sub">Aceda ao seu painel, acompanhe encomendas em tempo real e gira o seu perfil com total segurança.</p>
      <div class="pl-features">
        <div class="pl-feature"><div class="pl-feat-icon">📦</div>Acompanhe todas as suas encomendas</div>
        <div class="pl-feature"><div class="pl-feat-icon">⚡</div>Acesso rápido ao catálogo completo</div>
        <div class="pl-feature"><div class="pl-feat-icon">🔒</div>Dados protegidos e sessão segura</div>
        <div class="pl-feature"><div class="pl-feat-icon">🏢</div>Suporte dedicado à sua empresa</div>
      </div>
    </div>
    <div class="pl-bottom">© 2026 Hansa-Flex — Todos os direitos reservados</div>
  </div>
  <div class="panel-right">
    <a href="index.htm" class="back-link">← Voltar ao site</a>
    <div class="form-box">
      <h2>Bem-vindo</h2>
      <p class="subtitle">Entre na sua conta ou crie uma nova para começar.</p>
      <div class="tabs">
        <button class="tab-btn active" onclick="showTab('login',this)">Iniciar Sessão</button>
        <button class="tab-btn" onclick="showTab('registo',this)">Criar Conta</button>
      </div>
      <% if(msgErroFinal!=null&&!msgErroFinal.isEmpty()){ %><div class="err-box">⚠️ <%= msgErroFinal %></div><% } %>

      <!-- ── PAINEL LOGIN ── -->
      <div id="panel-login" class="form-panel active">
        <form method="post" action="iniciarSessao.jsp">
          <input type="hidden" name="acao" value="login">
          <div class="field"><label>Utilizador *</label><div class="input-wrap"><span class="input-icon">👤</span><input type="text" name="nome_de_usario" placeholder="O seu utilizador" required></div></div>
          <div class="field"><label>Palavra-passe *</label><div class="input-wrap"><span class="input-icon">🔑</span><input type="password" name="palavra_passe" id="pass-login" placeholder="A sua palavra-passe" required><button type="button" class="toggle-pass" onclick="togglePass('pass-login')">👁</button></div></div>
          <button type="submit" class="btn-submit">🔐 Entrar na minha conta</button>
        </form>
        <p class="alt-link" style="margin-top:10px;">
          <a href="recuperarSenha.jsp">🔑 Esqueceu a palavra-passe?</a>
        </p>
        <div class="divider">OU</div>
        <p class="alt-link">Não tem conta? <a href="#" onclick="showTabByName('registo')">Criar conta grátis</a></p>
      </div>

      <!-- ── PAINEL REGISTO ── -->
      <div id="panel-registo" class="form-panel">
        <form method="post" action="iniciarSessao.jsp">
          <input type="hidden" name="acao" value="registar">
          <div class="row2">
            <div class="field"><label>Nome *</label><div class="input-wrap"><span class="input-icon">👤</span><input type="text" name="nome" placeholder="Nome" required></div></div>
            <div class="field"><label>Telefone *</label><div class="input-wrap"><span class="input-icon">📞</span><input type="text" name="telefone" placeholder="9XXXXXXXX" maxlength="9" required></div></div>
          </div>
          <div class="field"><label>Email *</label><div class="input-wrap"><span class="input-icon">✉️</span><input type="email" name="email" placeholder="o.seu@email.com" required></div></div>
          <div class="field"><label>Utilizador *</label><div class="input-wrap"><span class="input-icon">🪪</span><input type="text" name="nome_de_usario" placeholder="Escolha um utilizador" required></div></div>
          <div class="field"><label>Palavra-passe *</label><div class="input-wrap"><span class="input-icon">🔑</span><input type="password" name="palavra_passe" id="pass-reg" placeholder="Crie uma palavra-passe" required><button type="button" class="toggle-pass" onclick="togglePass('pass-reg')">👁</button></div></div>
          <div class="field">
            <label>Pergunta de Segurança *</label>
            <div class="input-wrap">
              <span class="input-icon">🛡️</span>
              <select name="pergunta_seguranca" required style="width:100%;padding:11px 14px 11px 38px;border:1.5px solid #ddd;border-radius:8px;font-size:14px;background:#fff;outline:none;color:#333;">
                <option value="">-- Escolha uma pergunta --</option>
                <option value="Qual é o nome do seu animal de estimação?">Qual é o nome do seu animal de estimação?</option>
                <option value="Qual é o nome da sua cidade natal?">Qual é o nome da sua cidade natal?</option>
                <option value="Qual é o nome da sua mãe?">Qual é o nome da sua mãe?</option>
                <option value="Qual é o nome da sua escola primária?">Qual é o nome da sua escola primária?</option>
                <option value="Qual é o seu filme favorito?">Qual é o seu filme favorito?</option>
                <option value="Qual é o nome do seu melhor amigo de infância?">Qual é o nome do seu melhor amigo de infância?</option>
              </select>
            </div>
          </div>
          <div class="field">
            <label>Resposta *</label>
            <div class="input-wrap"><span class="input-icon">💬</span><input type="text" name="resposta_seguranca" placeholder="A sua resposta de segurança" required></div>
          </div>
          <button type="submit" class="btn-submit">✅ Criar conta</button>
        </form>
        <div class="divider">OU</div>
        <p class="alt-link">Já tem conta? <a href="#" onclick="showTabByName('login')">Iniciar sessão</a></p>
      </div>
    </div>
  </div>
</div>
<script>
function showTab(name,btn){document.querySelectorAll('.tab-btn').forEach(function(b){b.classList.remove('active');});document.querySelectorAll('.form-panel').forEach(function(p){p.classList.remove('active');});btn.classList.add('active');document.getElementById('panel-'+name).classList.add('active');}
function showTabByName(name){var idx=name==='login'?0:1;showTab(name,document.querySelectorAll('.tab-btn')[idx]);}
function togglePass(id){var inp=document.getElementById(id);inp.type=inp.type==='password'?'text':'password';}
</script>
</body>
</html>
