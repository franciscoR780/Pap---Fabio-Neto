<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    /* ── Verificação de sessão admin (dupla) ── */
    Integer admId = (Integer) session.getAttribute("adm_id");
    Object tipoAttr = session.getAttribute("tipoUtilizador");
    if (admId == null || !(tipoAttr instanceof Integer) || ((Integer)tipoAttr) != 1) {
        response.sendRedirect("login_admin.jsp");
        return;
    }

    String DB_URL  = "jdbc:mysql://localhost:3306/bd_pap?useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "";

    String acao = request.getParameter("acao");
    Connection conn = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        if ("inserir".equals(acao)) {
            String email    = request.getParameter("email");
            String telefone = request.getParameter("telefone");
            String nome     = request.getParameter("nome");
            String endereco = request.getParameter("endereco");
            // BUG CORRIGIDO: não forçar id manualmente — BD usa AUTO_INCREMENT
            if (nome != null && !nome.trim().isEmpty() && email != null && !email.trim().isEmpty()
                    && telefone != null && !telefone.trim().isEmpty()) {
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO t_cliente (email, telefone, nome, endereco, id_tipo_utilizador) VALUES (?,?,?,?,2)");
                ps.setString(1, email.trim());
                ps.setString(2, telefone.trim());
                ps.setString(3, nome.trim());
                ps.setString(4, endereco != null ? endereco.trim() : "");
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerircliente.jsp");
            return;
        }

        if ("excluir".equals(acao)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                PreparedStatement ps = conn.prepareStatement("DELETE FROM t_cliente WHERE id=?");
                ps.setInt(1, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerircliente.jsp");
            return;
        }

        if ("atualizar".equals(acao)) {
            String idStr    = request.getParameter("id");
            String email    = request.getParameter("email");
            String telefone = request.getParameter("telefone");
            String nome     = request.getParameter("nome");
            String endereco = request.getParameter("endereco");
            if (idStr != null && email != null && telefone != null && nome != null) {
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE t_cliente SET email=?, telefone=?, nome=?, endereco=? WHERE id=?");
                ps.setString(1, email.trim());
                ps.setString(2, telefone.trim());
                ps.setString(3, nome.trim());
                ps.setString(4, endereco != null ? endereco.trim() : "");
                ps.setInt(5, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerircliente.jsp");
            return;
        }

    } catch (Exception e) {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
        throw new ServletException("Erro de base de dados: " + e.getMessage(), e);
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Gerir Clientes — Hansa-Flex</title>
    <style>
        body{font-family:Arial;padding:40px;background:#f4f4f4}
        h2{color:#003d7a;margin-bottom:20px}
        .form-box{background:white;padding:24px;border-radius:8px;margin-bottom:30px;box-shadow:0 2px 8px rgba(0,0,0,0.08);max-width:600px}
        label{display:block;font-weight:600;color:#003d7a;margin-bottom:4px;font-size:13px}
        input,textarea{padding:8px 10px;margin-bottom:14px;width:100%;border:1px solid #ccc;border-radius:5px;font-size:14px;box-sizing:border-box}
        textarea{height:70px;resize:vertical}
        button{padding:8px 18px;background:#003d7a;color:white;border:none;cursor:pointer;border-radius:5px;font-size:14px;font-weight:600}
        button:hover{background:#001f3f}
        table{width:100%;border-collapse:collapse;background:white;border-radius:8px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)}
        th,td{border:1px solid #ddd;padding:10px;text-align:center;font-size:14px}
        th{background:#003d7a;color:white}
        tr:hover{background:#f0f5ff}
        a{text-decoration:none} .edit{color:#0056b3;font-weight:600} .del{color:#dc3545;font-weight:600}
        .back{display:inline-block;margin-bottom:20px;color:#003d7a;font-weight:600;text-decoration:none;font-size:14px}
        .back:hover{text-decoration:underline}
        .alert-err{background:#fee2e2;color:#dc2626;padding:10px 16px;border-radius:6px;margin-bottom:16px;font-weight:600}
    </style>
</head>
<body>
<a href="painel_admin.jsp" class="back">← Voltar ao painel</a>
<h2>👤 Gerir Clientes</h2>

<%
    Connection conn2 = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn2 = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        String editarId = request.getParameter("editar");
        int idEdit = 0;
        String emailEdit = "", telefoneEdit = "", nomeEdit = "", enderecoEdit = "";
        boolean modoEditar = false;

        if (editarId != null && !editarId.trim().isEmpty()) {
            PreparedStatement ps = conn2.prepareStatement("SELECT * FROM t_cliente WHERE id=?");
            ps.setInt(1, Integer.parseInt(editarId));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                idEdit       = rs.getInt("id");
                emailEdit    = rs.getString("email")    != null ? rs.getString("email")    : "";
                telefoneEdit = rs.getString("telefone") != null ? rs.getString("telefone") : "";
                nomeEdit     = rs.getString("nome")     != null ? rs.getString("nome")     : "";
                enderecoEdit = rs.getString("endereco") != null ? rs.getString("endereco") : "";
                modoEditar   = true;
            }
            rs.close(); ps.close();
        }
%>

<div class="form-box">
    <h3 style="color:#003d7a;margin-bottom:16px"><%= modoEditar ? "✏️ Editar Cliente" : "➕ Novo Cliente" %></h3>
    <form method="post" action="gerircliente.jsp">
        <input type="hidden" name="acao" value="<%= modoEditar ? "atualizar" : "inserir" %>">
        <% if (modoEditar) { %>
            <input type="hidden" name="id" value="<%= idEdit %>">
        <% } %>
        <%-- BUG CORRIGIDO: campo ID removido do formulário de inserção --%>

        <label>Nome *</label>
        <input type="text" name="nome" placeholder="Nome completo"
               value="<%= nomeEdit.replace("\"","&quot;") %>" required>

        <label>Email *</label>
        <input type="email" name="email" placeholder="email@exemplo.com"
               value="<%= emailEdit.replace("\"","&quot;") %>" required>

        <label>Telefone *</label>
        <input type="text" name="telefone" placeholder="9XXXXXXXX"
               value="<%= telefoneEdit.replace("\"","&quot;") %>" required>

        <label>Endereço</label>
        <textarea name="endereco" placeholder="Endereço completo"><%= enderecoEdit %></textarea>

        <button type="submit"><%= modoEditar ? "💾 Atualizar" : "➕ Adicionar" %></button>
        <% if (modoEditar) { %>
        <a href="gerircliente.jsp" style="margin-left:10px;color:#dc3545;font-size:14px">Cancelar</a>
        <% } %>
    </form>
</div>

<table>
    <thead>
        <tr>
            <th>ID</th><th>Nome</th><th>Email</th><th>Telefone</th><th>Endereço</th><th>Ações</th>
        </tr>
    </thead>
    <tbody>
<%
        Statement stmt = conn2.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM t_cliente ORDER BY nome");
        while (rs.next()) {
%>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td><%= rs.getString("nome") %></td>
            <td><%= rs.getString("email") %></td>
            <td><%= rs.getString("telefone") %></td>
            <td style="text-align:left"><%= rs.getString("endereco") %></td>
            <td>
                <a class="edit" href="gerircliente.jsp?editar=<%= rs.getInt("id") %>">✏️ Editar</a> &nbsp;|&nbsp;
                <a class="del" href="gerircliente.jsp?acao=excluir&id=<%= rs.getInt("id") %>"
                   onclick="return confirm('Excluir este cliente?')">🗑 Excluir</a>
            </td>
        </tr>
<%
        }
        rs.close(); stmt.close();
    } catch (Exception e) {
        out.println("<p class='alert-err'>Erro ao aceder à base de dados: " + e.getMessage() + "</p>");
    } finally {
        if (conn2 != null) try { conn2.close(); } catch (Exception ex) {}
    }
%>
    </tbody>
</table>
</body>
</html>
