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
    String dbUrl="jdbc:mysql://localhost:3306/bd_pap?useSSL=false&serverTimezone=UTC",dbUser="root",dbPass="";
    String acao=request.getParameter("acao"), msgErro="";

    /* ── LOGOUT do admin ── */
    if("logout".equals(acao)){
        session.removeAttribute("adm_id");
        session.removeAttribute("adm_nome");
        session.removeAttribute("adm_tipo");
        session.removeAttribute("admin_logado");
        session.removeAttribute("tipoUtilizador");
        response.sendRedirect("login_admin.jsp");
        return;
    }

    /* ── LOGIN do admin ── */
    if("login".equals(acao)){
        String nu=request.getParameter("nome_de_usario"), pp=request.getParameter("palavra_passe");
        if(nu==null||nu.trim().isEmpty()||pp==null||pp.trim().isEmpty()){
            msgErro="Preencha todos os campos.";
        } else {
            String ppHash = sha256(pp.trim());
            try{
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn=DriverManager.getConnection(dbUrl,dbUser,dbPass);
                PreparedStatement ps=conn.prepareStatement(
                    "SELECT id,nome FROM t_admin WHERE nome_de_usario=? AND palavra_passe=?");
                ps.setString(1,nu.trim()); ps.setString(2,ppHash);
                ResultSet rs=ps.executeQuery();
                if(rs.next()){
                    /* Definir TODOS os atributos de sessão necessários */
                    session.setAttribute("adm_id",        rs.getInt("id"));
                    session.setAttribute("adm_nome",      rs.getString("nome"));
                    session.setAttribute("adm_tipo",      1);
                    session.setAttribute("admin_logado",  Boolean.TRUE);
                    session.setAttribute("tipoUtilizador", 1); /* usado nos gerir*.jsp */
                    rs.close(); ps.close(); conn.close();
                    response.sendRedirect("painel_admin.jsp");
                    return;
                }
                rs.close(); ps.close(); conn.close();
                msgErro="Credenciais incorretas.";
            }catch(Exception e){ msgErro="Erro de ligação: "+e.getMessage(); }
        }
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Login Admin — Hansa-Flex</title>
<style>
  *{margin:0;padding:0;box-sizing:border-box}
  body{font-family:Arial,sans-serif;background:#0d1b2a;min-height:100vh;display:flex;align-items:center;justify-content:center}
  .box{background:white;padding:40px;border-radius:12px;width:100%;max-width:380px;box-shadow:0 8px 32px rgba(0,0,0,0.4)}
  .logo{text-align:center;font-size:22px;font-weight:900;color:#003d7a;letter-spacing:1px;margin-bottom:8px}
  .logo em{color:#c8a84b;font-style:normal}
  h2{text-align:center;font-size:16px;font-weight:600;margin-bottom:24px;color:#666}
  label{display:block;font-size:12px;font-weight:700;color:#003d7a;margin-bottom:4px;margin-top:14px}
  input{width:100%;padding:10px 12px;border:1.5px solid #ddd;border-radius:6px;font-size:14px;outline:none;transition:border .2s}
  input:focus{border-color:#003d7a}
  .btn{width:100%;padding:12px;background:#003d7a;color:white;border:none;border-radius:6px;font-size:15px;font-weight:700;cursor:pointer;margin-top:22px;transition:background .2s}
  .btn:hover{background:#001f3f}
  .err{background:#fee2e2;color:#dc2626;padding:10px;border-radius:6px;font-size:13px;font-weight:600;margin-top:14px;text-align:center}
  .back{display:block;text-align:center;margin-top:16px;color:#003d7a;font-size:13px;text-decoration:none}
  .back:hover{text-decoration:underline}
</style>
</head>
<body>
<div class="box">
  <div class="logo">HANSA<em>-FLEX</em></div>
  <h2>Painel de Administração</h2>
  <% if(msgErro!=null&&!msgErro.isEmpty()){ %><div class="err">⚠️ <%= msgErro %></div><% } %>
  <form method="post" action="login_admin.jsp">
    <input type="hidden" name="acao" value="login">
    <label>Utilizador</label>
    <input type="text" name="nome_de_usario" placeholder="Nome de utilizador" required autofocus>
    <label>Palavra-passe</label>
    <input type="password" name="palavra_passe" placeholder="Palavra-passe" required>
    <button type="submit" class="btn">🔐 Entrar no painel</button>
  </form>
  <a href="../index.htm" class="back">← Voltar ao site</a>
</div>
</body>
</html>
