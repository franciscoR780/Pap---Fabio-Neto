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
            String data      = request.getParameter("data");
            String mensagem  = request.getParameter("mensagem");
            String status    = request.getParameter("status");
            String idCliStr  = request.getParameter("id_cliente");
            if (data != null && mensagem != null && status != null && idCliStr != null) {
                int id_cliente = Integer.parseInt(idCliStr);
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO t_solicitacao_de_contato (data, mensagem, status, id_cliente) VALUES (?,?,?,?)");
                ps.setString(1, data);
                ps.setString(2, mensagem);
                ps.setString(3, status);
                ps.setInt(4, id_cliente);
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerircontato.jsp");
            return;
        }

        if ("excluir".equals(acao)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                int id = Integer.parseInt(idStr);
                PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM t_solicitacao_de_contato WHERE id=?");
                ps.setInt(1, id);
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerircontato.jsp");
            return;
        }

        if ("atualizar".equals(acao)) {
            String idStr     = request.getParameter("id");
            String data      = request.getParameter("data");
            String mensagem  = request.getParameter("mensagem");
            String status    = request.getParameter("status");
            String idCliStr  = request.getParameter("id_cliente");
            if (idStr != null && data != null && mensagem != null && status != null && idCliStr != null) {
                int id         = Integer.parseInt(idStr);
                int id_cliente = Integer.parseInt(idCliStr);
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE t_solicitacao_de_contato SET data=?, mensagem=?, status=?, id_cliente=? WHERE id=?");
                ps.setString(1, data);
                ps.setString(2, mensagem);
                ps.setString(3, status);
                ps.setInt(4, id_cliente);
                ps.setInt(5, id);
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerircontato.jsp");
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
    <title>Gerir Solicitações de Contato — Hansa-Flex</title>
    <style>
        body{font-family:Arial;padding:40px;background:#f4f4f4}
        h2{color:#003d7a;margin-bottom:20px}
        .form-box{background:white;padding:24px;border-radius:8px;margin-bottom:30px;box-shadow:0 2px 8px rgba(0,0,0,0.08);max-width:600px}
        label{display:block;font-weight:600;color:#003d7a;margin-bottom:4px;font-size:13px}
        input,select,textarea{padding:8px 10px;margin-bottom:14px;width:100%;border:1px solid #ccc;border-radius:5px;font-size:14px;box-sizing:border-box}
        textarea{height:80px;resize:vertical}
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
        .badge{display:inline-block;padding:3px 10px;border-radius:12px;font-size:12px;font-weight:600}
        .badge-pendente{background:#fef3c7;color:#92400e}
        .badge-resolvido{background:#dcfce7;color:#166534}
        .badge-analise{background:#dbeafe;color:#1e40af}
    </style>
</head>
<body>
<a href="painel_admin.jsp" class="back">← Voltar ao painel</a>
<h2>📬 Gerir Solicitações de Contato</h2>

<%
    Connection conn2 = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn2 = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        String editarId = request.getParameter("editar");
        int idEdit = 0;
        String dataEdit = "", mensagemEdit = "", statusEdit = "";
        int idClienteEdit = 0;
        boolean modoEditar = false;

        if (editarId != null && !editarId.trim().isEmpty()) {
            PreparedStatement ps = conn2.prepareStatement(
                "SELECT * FROM t_solicitacao_de_contato WHERE id=?");
            ps.setInt(1, Integer.parseInt(editarId));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                idEdit        = rs.getInt("id");
                dataEdit      = rs.getString("data")     != null ? rs.getString("data")     : "";
                mensagemEdit  = rs.getString("mensagem") != null ? rs.getString("mensagem") : "";
                statusEdit    = rs.getString("status")   != null ? rs.getString("status")   : "";
                idClienteEdit = rs.getInt("id_cliente");
                modoEditar    = true;
            }
            rs.close(); ps.close();
        }
%>

<div class="form-box">
    <h3 style="color:#003d7a;margin-bottom:16px"><%= modoEditar ? "✏️ Editar Contacto" : "➕ Novo Contacto" %></h3>
    <form method="post" action="gerircontato.jsp">
        <input type="hidden" name="acao" value="<%= modoEditar ? "atualizar" : "inserir" %>">
        <% if (modoEditar) { %><input type="hidden" name="id" value="<%= idEdit %>"><% } %>

        <label>Data</label>
        <input type="date" name="data" value="<%= dataEdit %>" required>

        <label>Mensagem</label>
        <textarea name="mensagem" placeholder="Mensagem do contato" required><%= mensagemEdit %></textarea>

        <label>Status</label>
        <select name="status" required>
            <option value="">-- Selecione --</option>
            <option value="Pendente"   <%= "Pendente".equals(statusEdit)   ? "selected" : "" %>>Pendente</option>
            <option value="Em análise" <%= "Em análise".equals(statusEdit) ? "selected" : "" %>>Em análise</option>
            <option value="Resolvido"  <%= "Resolvido".equals(statusEdit)  ? "selected" : "" %>>Resolvido</option>
        </select>

        <label>ID do Cliente</label>
        <input type="number" name="id_cliente" placeholder="ID do cliente"
               value="<%= idClienteEdit %>" required min="1">

        <button type="submit"><%= modoEditar ? "💾 Atualizar" : "➕ Adicionar" %></button>
        <% if (modoEditar) { %>
        <a href="gerircontato.jsp" style="margin-left:10px;color:#dc3545;font-size:14px">Cancelar</a>
        <% } %>
    </form>
</div>

<table>
    <thead>
        <tr>
            <th>ID</th><th>Data</th><th>Mensagem</th><th>Status</th><th>ID Cliente</th><th>Ações</th>
        </tr>
    </thead>
    <tbody>
<%
        Statement stmt = conn2.createStatement();
        ResultSet rs = stmt.executeQuery(
            "SELECT * FROM t_solicitacao_de_contato ORDER BY data DESC");
        while (rs.next()) {
            String statusVal = rs.getString("status");
            String badgeClass = "Resolvido".equals(statusVal)  ? "badge-resolvido"
                              : "Em análise".equals(statusVal) ? "badge-analise"
                              : "badge-pendente";
%>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td><%= rs.getString("data") %></td>
            <td style="text-align:left;font-size:13px"><%= rs.getString("mensagem") %></td>
            <td><span class="badge <%= badgeClass %>"><%= statusVal %></span></td>
            <td><%= rs.getInt("id_cliente") %></td>
            <td>
                <a class="edit" href="gerircontato.jsp?editar=<%= rs.getInt("id") %>">✏️ Editar</a> &nbsp;|&nbsp;
                <a class="del" href="gerircontato.jsp?acao=excluir&id=<%= rs.getInt("id") %>"
                   onclick="return confirm('Excluir esta solicitação?')">🗑 Excluir</a>
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
