<%@ page import="java.sql.*,java.util.*" %>
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
            String status    = request.getParameter("status");
            String data      = request.getParameter("data");
            String idCliStr  = request.getParameter("id_cliente");
            String filialStr = request.getParameter("filial");
            // BUG CORRIGIDO: não forçar id manualmente — BD usa AUTO_INCREMENT
            if (status != null && data != null && idCliStr != null && filialStr != null) {
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO t_pedido (status, data, id_cliente, filial) VALUES (?,?,?,?)");
                ps.setString(1, status);
                ps.setString(2, data);
                ps.setInt(3, Integer.parseInt(idCliStr));
                ps.setInt(4, Integer.parseInt(filialStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirPedido.jsp");
            return;
        }

        if ("excluir".equals(acao)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                PreparedStatement ps = conn.prepareStatement("DELETE FROM t_pedido WHERE id=?");
                ps.setInt(1, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirPedido.jsp");
            return;
        }

        if ("atualizar".equals(acao)) {
            String idStr     = request.getParameter("id");
            String status    = request.getParameter("status");
            String data      = request.getParameter("data");
            String idCliStr  = request.getParameter("id_cliente");
            String filialStr = request.getParameter("filial");
            if (idStr != null && status != null && data != null && idCliStr != null && filialStr != null) {
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE t_pedido SET status=?, data=?, id_cliente=?, filial=? WHERE id=?");
                ps.setString(1, status);
                ps.setString(2, data);
                ps.setInt(3, Integer.parseInt(idCliStr));
                ps.setInt(4, Integer.parseInt(filialStr));
                ps.setInt(5, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirPedido.jsp");
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
    <title>Gerir Pedidos — Hansa-Flex</title>
    <style>
        body{font-family:Arial;padding:40px;background:#f4f4f4}
        h2{color:#003d7a;margin-bottom:20px}
        .form-box{background:white;padding:24px;border-radius:8px;margin-bottom:30px;box-shadow:0 2px 8px rgba(0,0,0,0.08);max-width:600px}
        label{display:block;font-weight:600;color:#003d7a;margin-bottom:4px;font-size:13px}
        input,select{padding:8px 10px;margin-bottom:14px;width:100%;border:1px solid #ccc;border-radius:5px;font-size:14px;box-sizing:border-box}
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
<h2>🛒 Gerir Pedidos</h2>

<%
    Connection conn2 = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn2 = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        String editarId = request.getParameter("editar");
        int idEdit = 0, idClienteEdit = 0, filialEdit = 0;
        String statusEdit = "", dataEdit = "";
        boolean modoEditar = false;

        if (editarId != null && !editarId.trim().isEmpty()) {
            PreparedStatement ps = conn2.prepareStatement("SELECT * FROM t_pedido WHERE id=?");
            ps.setInt(1, Integer.parseInt(editarId));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                idEdit        = rs.getInt("id");
                statusEdit    = rs.getString("status") != null ? rs.getString("status") : "";
                dataEdit      = rs.getString("data")   != null ? rs.getString("data")   : "";
                idClienteEdit = rs.getInt("id_cliente");
                filialEdit    = rs.getInt("filial");
                modoEditar    = true;
            }
            rs.close(); ps.close();
        }

        /* Carregar filiais para dropdown */
        List<Integer> filiaisIds   = new ArrayList<>();
        List<String>  filiaisNomes = new ArrayList<>();
        ResultSet rsF = conn2.createStatement().executeQuery(
            "SELECT id, nome, cidade FROM t_unidade_filial ORDER BY nome");
        while (rsF.next()) {
            filiaisIds.add(rsF.getInt("id"));
            filiaisNomes.add(rsF.getString("nome") + " — " + rsF.getString("cidade"));
        }
        rsF.close();
%>

<div class="form-box">
    <h3 style="color:#003d7a;margin-bottom:16px"><%= modoEditar ? "✏️ Editar Pedido" : "➕ Novo Pedido" %></h3>
    <form method="post" action="gerirPedido.jsp">
        <input type="hidden" name="acao" value="<%= modoEditar ? "atualizar" : "inserir" %>">
        <% if (modoEditar) { %>
            <input type="hidden" name="id" value="<%= idEdit %>">
        <% } %>
        <%-- BUG CORRIGIDO: campo ID removido do formulário de inserção — BD usa AUTO_INCREMENT --%>

        <label>Status *</label>
        <select name="status" required>
            <option value="">-- Selecione --</option>
            <option value="Pendente"    <%= "Pendente".equals(statusEdit)    ? "selected" : "" %>>Pendente</option>
            <option value="Em processo" <%= "Em processo".equals(statusEdit) ? "selected" : "" %>>Em processo</option>
            <option value="Concluído"   <%= "Concluído".equals(statusEdit)   ? "selected" : "" %>>Concluído</option>
            <option value="Cancelado"   <%= "Cancelado".equals(statusEdit)   ? "selected" : "" %>>Cancelado</option>
        </select>

        <label>Data *</label>
        <input type="date" name="data" value="<%= dataEdit %>" required>

        <label>ID do Cliente *</label>
        <input type="number" name="id_cliente" placeholder="ID do cliente"
               value="<%= idClienteEdit %>" required min="1">

        <label>Filial *</label>
        <select name="filial" required>
            <option value="">-- Selecione a filial --</option>
            <% for (int f = 0; f < filiaisIds.size(); f++) {
                int fId = filiaisIds.get(f);
                boolean sel = (fId == filialEdit);
            %>
            <option value="<%= fId %>" <%= sel ? "selected" : "" %>><%= filiaisNomes.get(f) %></option>
            <% } %>
        </select>

        <button type="submit"><%= modoEditar ? "💾 Atualizar" : "➕ Adicionar" %></button>
        <% if (modoEditar) { %>
        <a href="gerirPedido.jsp" style="margin-left:10px;color:#dc3545;font-size:14px">Cancelar</a>
        <% } %>
    </form>
</div>

<table>
    <thead>
        <tr>
            <th>ID</th><th>Status</th><th>Data</th><th>ID Cliente</th><th>Filial</th><th>Ações</th>
        </tr>
    </thead>
    <tbody>
<%
        Statement stmt = conn2.createStatement();
        ResultSet rs = stmt.executeQuery(
            "SELECT p.*, f.nome AS filial_nome FROM t_pedido p " +
            "LEFT JOIN t_unidade_filial f ON p.filial = f.id ORDER BY p.id DESC");
        while (rs.next()) {
            String filialNome = rs.getString("filial_nome");
            if (filialNome == null) filialNome = "ID: " + rs.getInt("filial");
%>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td><%= rs.getString("status") %></td>
            <td><%= rs.getString("data") %></td>
            <td><%= rs.getInt("id_cliente") %></td>
            <td><%= filialNome %></td>
            <td>
                <a class="edit" href="gerirPedido.jsp?editar=<%= rs.getInt("id") %>">✏️ Editar</a> &nbsp;|&nbsp;
                <a class="del" href="gerirPedido.jsp?acao=excluir&id=<%= rs.getInt("id") %>"
                   onclick="return confirm('Excluir este pedido? Os itens e orçamentos associados também serão afetados.')">🗑 Excluir</a>
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
