<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ page import="java.sql.*, java.security.MessageDigest, java.nio.charset.StandardCharsets" %>
<%!
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
    String DB_URL  = "jdbc:mysql://localhost:3306/bd_pap?useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "";

    String passo    = request.getParameter("passo");   // "1", "2", "3"
    String msgErro  = "";
    String msgOk    = "";

    // Variáveis que fluem entre passos (via campos hidden)
    String utilizador         = request.getParameter("utilizador") != null ? request.getParameter("utilizador").trim() : "";
    String perguntaGuardada   = "";
    boolean passoOkUtilizador = false;

    /* ══════════════════════════════════════════
       PASSO 1 → Verificar se utilizador existe
       ══════════════════════════════════════════ */
    if ("1".equals(passo) && !utilizador.isEmpty()) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            PreparedStatement ps = conn.prepareStatement(
                "SELECT pergunta_seguranca FROM t_cliente WHERE nome_de_usario=?");
            ps.setString(1, utilizador);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                perguntaGuardada   = rs.getString("pergunta_seguranca");
                passoOkUtilizador  = true;
                if (perguntaGuardada == null || perguntaGuardada.trim().isEmpty()) {
                    msgErro = "Esta conta não tem pergunta de segurança configurada. Contacte o suporte.";
                    passoOkUtilizador = false;
                }
            } else {
                msgErro = "Utilizador não encontrado.";
            }
            rs.close(); ps.close(); conn.close();
        } catch (Exception e) {
            msgErro = "Erro de ligação: " + e.getMessage();
        }
    }

    /* ══════════════════════════════════════════
       PASSO 2 → Verificar resposta de segurança
       ══════════════════════════════════════════ */
    String respostaCorreta = "";
    boolean passoOkResposta = false;
    if ("2".equals(passo)) {
        String respostaInput = request.getParameter("resposta") != null ? request.getParameter("resposta").trim() : "";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            PreparedStatement ps = conn.prepareStatement(
                "SELECT resposta_seguranca, pergunta_seguranca FROM t_cliente WHERE nome_de_usario=?");
            ps.setString(1, utilizador);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                perguntaGuardada = rs.getString("pergunta_seguranca");
                respostaCorreta  = rs.getString("resposta_seguranca");
                // Comparação case-insensitive após trim
                if (respostaCorreta != null && respostaCorreta.trim().equalsIgnoreCase(respostaInput)) {
                    passoOkResposta = true;
                } else {
                    msgErro = "Resposta incorreta. Tente novamente.";
                    passoOkUtilizador = true; // manter no passo 2
                }
            } else {
                msgErro = "Utilizador não encontrado.";
            }
            rs.close(); ps.close(); conn.close();
        } catch (Exception e) {
            msgErro = "Erro de ligação: " + e.getMessage();
        }
    }

    /* ══════════════════════════════════════════
       PASSO 3 → Guardar nova palavra-passe
       ══════════════════════════════════════════ */
    boolean concluido = false;
    if ("3".equals(passo)) {
        String novaSenha   = request.getParameter("nova_senha")    != null ? request.getParameter("nova_senha").trim()    : "";
        String confirma    = request.getParameter("confirma_senha") != null ? request.getParameter("confirma_senha").trim() : "";
        if (novaSenha.isEmpty() || confirma.isEmpty()) {
            msgErro = "Preencha ambos os campos.";
            passoOkResposta = true;
        } else if (!novaSenha.equals(confirma)) {
            msgErro = "As palavras-passe não coincidem.";
            passoOkResposta = true;
        } else if (novaSenha.length() < 6) {
            msgErro = "A palavra-passe deve ter pelo menos 6 caracteres.";
            passoOkResposta = true;
        } else {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE t_cliente SET palavra_passe=? WHERE nome_de_usario=?");
                ps.setString(1, sha256(novaSenha));
                ps.setString(2, utilizador);
                int rows = ps.executeUpdate();
                ps.close(); conn.close();
                if (rows > 0) { concluido = true; }
                else          { msgErro = "Não foi possível atualizar. Utilizador não encontrado."; passoOkResposta = true; }
            } catch (Exception e) {
                msgErro = "Erro de ligação: " + e.getMessage();
                passoOkResposta = true;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Recuperar Senha — Hansa-Flex</title>
<link rel="stylesheet" href="css/shared.css">
<link rel="stylesheet" href="css/iniciarSessao.css">
<style>
  .step-bar{display:flex;align-items:center;justify-content:center;gap:0;margin-bottom:32px;}
  .step{display:flex;flex-direction:column;align-items:center;gap:6px;position:relative;}
  .step-circle{width:36px;height:36px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:14px;border:2px solid #ddd;background:#fff;color:#aaa;transition:all .3s;}
  .step.done .step-circle{background:#15803d;border-color:#15803d;color:#fff;}
  .step.active .step-circle{background:#003d7a;border-color:#003d7a;color:#fff;}
  .step-label{font-size:11px;color:#aaa;font-weight:600;white-space:nowrap;}
  .step.active .step-label,.step.done .step-label{color:#003d7a;}
  .step-line{width:60px;height:2px;background:#ddd;margin-bottom:20px;}
  .step-line.done{background:#15803d;}
  .field{margin-bottom:16px;}
  .field label{display:block;font-size:13px;font-weight:700;color:#003d7a;margin-bottom:6px;}
  .field input,.field select{width:100%;padding:11px 14px;border:1.5px solid #ddd;border-radius:8px;font-size:14px;outline:none;transition:border .2s;background:#fff;}
  .field input:focus,.field select:focus{border-color:#003d7a;}
  .err-box{background:#fee2e2;color:#dc2626;padding:12px 16px;border-radius:8px;font-size:13px;font-weight:600;margin-bottom:16px;}
  .ok-box{background:#f0fdf4;border:1px solid #bbf7d0;color:#15803d;padding:20px;border-radius:10px;text-align:center;margin-bottom:20px;}
  .ok-box h3{font-size:18px;font-weight:800;margin-bottom:6px;}
  .ok-box p{font-size:13px;}
  .btn-submit{width:100%;padding:13px;background:#003d7a;color:#fff;border:none;border-radius:8px;font-size:15px;font-weight:700;cursor:pointer;margin-top:8px;transition:background .2s;}
  .btn-submit:hover{background:#001f3f;}
  .pergunta-box{background:#eff6ff;border:1px solid #bfdbfe;border-radius:8px;padding:14px 16px;margin-bottom:20px;font-size:14px;color:#1e3a6e;font-weight:600;}
  .pergunta-box span{display:block;font-size:11px;font-weight:600;color:#3b82f6;text-transform:uppercase;letter-spacing:.5px;margin-bottom:4px;}
</style>
</head>
<body>
<div class="page">
  <div class="panel-left">
    <div class="pl-content">
      <div class="pl-logo">HANSA<em>-FLEX</em></div>
      <h1 class="pl-title">Recuperar<em>palavra-passe.</em></h1>
      <p class="pl-sub">Siga os 3 passos para recuperar o acesso à sua conta de forma segura.</p>
      <div class="pl-features">
        <div class="pl-feature"><div class="pl-feat-icon">1️⃣</div>Confirme o seu utilizador</div>
        <div class="pl-feature"><div class="pl-feat-icon">2️⃣</div>Responda à pergunta de segurança</div>
        <div class="pl-feature"><div class="pl-feat-icon">3️⃣</div>Defina uma nova palavra-passe</div>
      </div>
    </div>
    <div class="pl-bottom">© 2026 Hansa-Flex — Todos os direitos reservados</div>
  </div>

  <div class="panel-right">
    <a href="iniciarSessao.jsp" class="back-link">← Voltar ao login</a>
    <div class="form-box">
      <h2>Recuperar Conta</h2>
      <p class="subtitle">Siga os passos para redefinir a sua palavra-passe.</p>

      <!-- BARRA DE PASSOS -->
      <div class="step-bar">
        <div class="step <%= (!passoOkUtilizador && !passoOkResposta && !concluido) ? "active" : "done" %>">
          <div class="step-circle"><%= (!passoOkUtilizador && !passoOkResposta && !concluido) ? "1" : "✓" %></div>
          <div class="step-label">Utilizador</div>
        </div>
        <div class="step-line <%= (passoOkUtilizador || passoOkResposta || concluido) ? "done" : "" %>"></div>
        <div class="step <%= passoOkResposta || concluido ? "done" : (passoOkUtilizador ? "active" : "") %>">
          <div class="step-circle"><%= (passoOkResposta || concluido) ? "✓" : "2" %></div>
          <div class="step-label">Segurança</div>
        </div>
        <div class="step-line <%= (passoOkResposta || concluido) ? "done" : "" %>"></div>
        <div class="step <%= concluido ? "done" : (passoOkResposta ? "active" : "") %>">
          <div class="step-circle"><%= concluido ? "✓" : "3" %></div>
          <div class="step-label">Nova Senha</div>
        </div>
      </div>

      <% if (!msgErro.isEmpty()) { %>
        <div class="err-box">⚠️ <%= msgErro %></div>
      <% } %>

      <!-- ── CONCLUÍDO ── -->
      <% if (concluido) { %>
        <div class="ok-box">
          <div style="font-size:48px;margin-bottom:12px;">✅</div>
          <h3>Palavra-passe alterada!</h3>
          <p>Pode agora iniciar sessão com a sua nova palavra-passe.</p>
        </div>
        <a href="iniciarSessao.jsp" class="btn-submit" style="display:block;text-align:center;text-decoration:none;">
          🔐 Ir para o Login
        </a>

      <!-- ── PASSO 3: nova senha ── -->
      <% } else if (passoOkResposta) { %>
        <form method="post" action="recuperarSenha.jsp">
          <input type="hidden" name="passo"      value="3">
          <input type="hidden" name="utilizador" value="<%= utilizador %>">
          <div class="field">
            <label>Nova Palavra-passe *</label>
            <input type="password" name="nova_senha" placeholder="Mínimo 6 caracteres" required minlength="6">
          </div>
          <div class="field">
            <label>Confirmar Palavra-passe *</label>
            <input type="password" name="confirma_senha" placeholder="Repita a nova palavra-passe" required>
          </div>
          <button type="submit" class="btn-submit">🔒 Guardar Nova Senha</button>
        </form>

      <!-- ── PASSO 2: pergunta de segurança ── -->
      <% } else if (passoOkUtilizador) { %>
        <div class="pergunta-box">
          <span>Pergunta de Segurança</span>
          <%= perguntaGuardada %>
        </div>
        <form method="post" action="recuperarSenha.jsp">
          <input type="hidden" name="passo"      value="2">
          <input type="hidden" name="utilizador" value="<%= utilizador %>">
          <div class="field">
            <label>A sua resposta *</label>
            <input type="text" name="resposta" placeholder="Escreva a sua resposta" required autofocus>
          </div>
          <button type="submit" class="btn-submit">➡️ Verificar Resposta</button>
        </form>

      <!-- ── PASSO 1: utilizador ── -->
      <% } else { %>
        <form method="post" action="recuperarSenha.jsp">
          <input type="hidden" name="passo" value="1">
          <div class="field">
            <label>Nome de Utilizador *</label>
            <input type="text" name="utilizador" placeholder="O seu nome de utilizador"
                   value="<%= utilizador %>" required autofocus>
          </div>
          <button type="submit" class="btn-submit">➡️ Continuar</button>
        </form>
        <div class="divider">OU</div>
        <p class="alt-link">Lembra-se da senha? <a href="iniciarSessao.jsp">Iniciar sessão</a></p>
      <% } %>

    </div>
  </div>
</div>
</body>
</html>
