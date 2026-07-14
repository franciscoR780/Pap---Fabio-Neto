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
            String tipoNome = request.getParameter("tipo");
            if (tipoNome != null && !tipoNome.trim().isEmpty()) {
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO t_tipo_utilizador (tipo) VALUES (?)");
                ps.setString(1, tipoNome.trim());
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirTipoUtilizador.jsp");
            return;
        }

        if ("excluir".equals(acao)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM t_tipo_utilizador WHERE id=?");
                ps.setInt(1, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirTipoUtilizador.jsp");
            return;
        }

        if ("atualizar".equals(acao)) {
            String idStr    = request.getParameter("id");
            String tipoNome = request.getParameter("tipo");
            if (idStr != null && tipoNome != null && !tipoNome.trim().isEmpty()) {
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE t_tipo_utilizador SET tipo=? WHERE id=?");
                ps.setString(1, tipoNome.trim());
                ps.setInt(2, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirTipoUtilizador.jsp");
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
    <title>Gerir Tipos de Utilizador — Hansa-Flex</title>
    <style>
        body{font-family:Arial;padding:40px;background:#f4f4f4}
        h2{color:#003d7a;margin-bottom:20px}
        .form-box{background:white;padding:24px;border-radius:8px;margin-bottom:30px;
                  box-shadow:0 2px 8px rgba(0,0,0,0.08);max-width:500px}
        label{display:block;font-weight:600;color:#003d7a;margin-bottom:4px;font-size:13px}
        input{padding:8px 10px;margin-bottom:14px;width:100%;border:1px solid #ccc;
              border-radius:5px;font-size:14px;box-sizing:border-box}
        button{padding:8px 18px;background:#003d7a;color:white;border:none;cursor:pointer;
               border-radius:5px;font-size:14px;font-weight:600}
        button:hover{background:#001f3f}
        table{width:100%;border-collapse:collapse;background:white;border-radius:8px;
              overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);max-width:600px}
        th,td{border:1px solid #ddd;padding:12px 16px;font-size:14px}
        th{background:#003d7a;color:white;text-align:left}
        td{text-align:left}
        tr:hover{background:#f0f5ff}
        a{text-decoration:none}
        .edit{color:#0056b3;font-weight:600}
        .del{color:#dc3545;font-weight:600}
        .back{display:inline-block;margin-bottom:20px;color:#003d7a;font-weight:600;
              text-decoration:none;font-size:14px}
        .back:hover{text-decoration:underline}
        .alert-err{background:#fee2e2;color:#dc2626;padding:10px 16px;border-radius:6px;
                   margin-bottom:16px;font-weight:600}
        .warn{background:#fef9c3;border:1px solid #fde047;color:#854d0e;padding:10px 14px;
              border-radius:6px;font-size:13px;margin-bottom:16px}
    </style>
</head>
<body>
<a href="painel_admin.jsp" class="back">← Voltar ao painel</a>
<h2>👤 Gerir Tipos de Utilizador</h2>

<div class="warn">
    ⚠️ Os tipos de utilizador estão associados a clientes e administradores. Tenha cuidado ao eliminar ou renomear registos existentes.
</div>

<%
    Connection conn2 = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn2 = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        String editarId = request.getParameter("editar");
        int    idEdit   = 0;
        String tipoEdit = "";
        boolean modoEditar = false;

        if (editarId != null && !editarId.trim().isEmpty()) {
            PreparedStatement ps = conn2.prepareStatement(
                "SELECT * FROM t_tipo_utilizador WHERE id=?");
            ps.setInt(1, Integer.parseInt(editarId));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                idEdit     = rs.getInt("id");
                tipoEdit   = rs.getString("tipo") != null ? rs.getString("tipo") : "";
                modoEditar = true;
            }
            rs.close(); ps.close();
        }
%>

<div class="form-box">
    <h3 style="color:#003d7a;margin-bottom:16px">
        <%= modoEditar ? "✏️ Editar Tipo" : "➕ Novo Tipo" %>
    </h3>
    <form method="post" action="gerirTipoUtilizador.jsp">
        <input type="hidden" name="acao" value="<%= modoEditar ? "atualizar" : "inserir" %>">
        <% if (modoEditar) { %>
            <input type="hidden" name="id" value="<%= idEdit %>">
        <% } %>

        <label>Nome do Tipo</label>
        <input type="text" name="tipo" placeholder="Ex: Admin, Cliente, Gestor…"
               value="<%= tipoEdit.replace("\"","&quot;") %>" required>

        <button type="submit"><%= modoEditar ? "💾 Atualizar" : "➕ Adicionar" %></button>
        <% if (modoEditar) { %>
        <a href="gerirTipoUtilizador.jsp" style="margin-left:10px;color:#dc3545;font-size:14px">Cancelar</a>
        <% } %>
    </form>
</div>

<table>
    <thead>
        <tr>
            <th style="width:60px">ID</th>
            <th>Tipo</th>
            <th style="width:150px;text-align:center">Ações</th>
        </tr>
    </thead>
    <tbody>
<%
        ResultSet rs = conn2.createStatement().executeQuery(
            "SELECT * FROM t_tipo_utilizador ORDER BY id");
        while (rs.next()) {
%>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td><%= rs.getString("tipo") %></td>
            <td style="text-align:center">
                <a class="edit" href="gerirTipoUtilizador.jsp?editar=<%= rs.getInt("id") %>">✏️ Editar</a>
                &nbsp;|&nbsp;
                <a class="del"
                   href="gerirTipoUtilizador.jsp?acao=excluir&id=<%= rs.getInt("id") %>"
                   onclick="return confirm('Eliminar este tipo? Pode afetar utilizadores associados.')">
                   🗑 Excluir
                </a>
            </td>
        </tr>
<%
        }
        rs.close();
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
