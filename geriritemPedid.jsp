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
            String qtdStr   = request.getParameter("quantidade");
            String stStr    = request.getParameter("subtotal");
            String puStr    = request.getParameter("preco_unitario");
            String ipStr    = request.getParameter("id_produto");
            String ipeStr   = request.getParameter("id_pedido");
            if (qtdStr != null && stStr != null && puStr != null && ipStr != null && ipeStr != null) {
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO t_item_de_pedido (quantidade, subtotal, preco_unitario, id_produto, id_pedido) VALUES (?,?,?,?,?)");
                ps.setInt(1, Integer.parseInt(qtdStr));
                ps.setDouble(2, Double.parseDouble(stStr));
                ps.setDouble(3, Double.parseDouble(puStr));
                ps.setInt(4, Integer.parseInt(ipStr));
                ps.setInt(5, Integer.parseInt(ipeStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("geriritemPedid.jsp");
            return;
        }

        if ("excluir".equals(acao)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                PreparedStatement ps = conn.prepareStatement("DELETE FROM t_item_de_pedido WHERE id=?");
                ps.setInt(1, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("geriritemPedid.jsp");
            return;
        }

        if ("atualizar".equals(acao)) {
            String idStr  = request.getParameter("id");
            String qtdStr = request.getParameter("quantidade");
            String stStr  = request.getParameter("subtotal");
            String puStr  = request.getParameter("preco_unitario");
            String ipStr  = request.getParameter("id_produto");
            String ipeStr = request.getParameter("id_pedido");
            if (idStr != null && qtdStr != null && stStr != null && puStr != null && ipStr != null && ipeStr != null) {
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE t_item_de_pedido SET quantidade=?, subtotal=?, preco_unitario=?, id_produto=?, id_pedido=? WHERE id=?");
                ps.setInt(1, Integer.parseInt(qtdStr));
                ps.setDouble(2, Double.parseDouble(stStr));
                ps.setDouble(3, Double.parseDouble(puStr));
                ps.setInt(4, Integer.parseInt(ipStr));
                ps.setInt(5, Integer.parseInt(ipeStr));
                ps.setInt(6, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("geriritemPedid.jsp");
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
    <title>Gerir Itens de Pedido — Hansa-Flex</title>
    <style>
        body{font-family:Arial;padding:40px;background:#f4f4f4}
        h2{color:#003d7a;margin-bottom:20px}
        .form-box{background:white;padding:24px;border-radius:8px;margin-bottom:30px;box-shadow:0 2px 8px rgba(0,0,0,0.08);max-width:600px}
        label{display:block;font-weight:600;color:#003d7a;margin-bottom:4px;font-size:13px}
        input{padding:8px 10px;margin-bottom:14px;width:100%;border:1px solid #ccc;border-radius:5px;font-size:14px;box-sizing:border-box}
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
        .hint{font-size:11px;color:#888;margin-top:-10px;margin-bottom:12px;display:block}
    </style>
</head>
<body>
<a href="painel_admin.jsp" class="back">← Voltar ao painel</a>
<h2>📦 Gerir Itens de Pedido</h2>

<%
    Connection conn2 = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn2 = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        String editarId = request.getParameter("editar");
        int idEdit = 0, quantidadeEdit = 0, idProdutoEdit = 0, idPedidoEdit = 0;
        double subtotalEdit = 0, precoUnitarioEdit = 0;
        boolean modoEditar = false;

        if (editarId != null && !editarId.trim().isEmpty()) {
            PreparedStatement ps = conn2.prepareStatement(
                "SELECT * FROM t_item_de_pedido WHERE id=?");
            ps.setInt(1, Integer.parseInt(editarId));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                idEdit            = rs.getInt("id");
                quantidadeEdit    = rs.getInt("quantidade");
                subtotalEdit      = rs.getDouble("subtotal");
                precoUnitarioEdit = rs.getDouble("preco_unitario");
                idProdutoEdit     = rs.getInt("id_produto");
                idPedidoEdit      = rs.getInt("id_pedido");
                modoEditar        = true;
            }
            rs.close(); ps.close();
        }
%>

<div class="form-box">
    <h3 style="color:#003d7a;margin-bottom:16px"><%= modoEditar ? "✏️ Editar Item" : "➕ Novo Item de Pedido" %></h3>
    <form method="post" action="geriritemPedid.jsp">
        <input type="hidden" name="acao" value="<%= modoEditar ? "atualizar" : "inserir" %>">
        <% if (modoEditar) { %><input type="hidden" name="id" value="<%= idEdit %>"><% } %>

        <label>Quantidade *</label>
        <input type="number" name="quantidade" placeholder="Quantidade"
               value="<%= quantidadeEdit %>" required min="1">

        <label>Preço Unitário (€) *</label>
        <input type="number" step="0.01" name="preco_unitario" placeholder="0.00"
               value="<%= precoUnitarioEdit %>" required min="0">

        <label>Subtotal (€) *</label>
        <input type="number" step="0.01" name="subtotal" id="subtotal" placeholder="0.00"
               value="<%= subtotalEdit %>" required min="0">
        <span class="hint">Calculado automaticamente ao preencher Qtd × Preço Unitário.</span>

        <label>ID do Produto *</label>
        <input type="number" name="id_produto" placeholder="ID do produto"
               value="<%= idProdutoEdit %>" required min="1">

        <label>ID do Pedido *</label>
        <input type="number" name="id_pedido" placeholder="ID do pedido"
               value="<%= idPedidoEdit %>" required min="1">

        <button type="submit"><%= modoEditar ? "💾 Atualizar" : "➕ Adicionar" %></button>
        <% if (modoEditar) { %>
        <a href="geriritemPedid.jsp" style="margin-left:10px;color:#dc3545;font-size:14px">Cancelar</a>
        <% } %>
    </form>
</div>

<table>
    <thead>
        <tr>
            <th>ID</th><th>Quantidade</th><th>Preço Unitário</th><th>Subtotal</th><th>ID Produto</th><th>ID Pedido</th><th>Ações</th>
        </tr>
    </thead>
    <tbody>
<%
        Statement stmt = conn2.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM t_item_de_pedido ORDER BY id DESC");
        while (rs.next()) {
%>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td><%= rs.getInt("quantidade") %></td>
            <td style="text-align:right"><%= String.format("%.2f €", rs.getDouble("preco_unitario")) %></td>
            <td style="text-align:right"><%= String.format("%.2f €", rs.getDouble("subtotal")) %></td>
            <td><%= rs.getInt("id_produto") %></td>
            <td><%= rs.getInt("id_pedido") %></td>
            <td>
                <a class="edit" href="geriritemPedid.jsp?editar=<%= rs.getInt("id") %>">✏️ Editar</a> &nbsp;|&nbsp;
                <a class="del" href="geriritemPedid.jsp?acao=excluir&id=<%= rs.getInt("id") %>"
                   onclick="return confirm('Excluir este item?')">🗑 Excluir</a>
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
<script>
/* Auto-calcula subtotal ao mudar qtd ou preço unitário */
(function(){
    var q = document.querySelector('[name="quantidade"]');
    var p = document.querySelector('[name="preco_unitario"]');
    var s = document.getElementById('subtotal');
    function calc(){ if(q&&p&&s){ var v=parseFloat(q.value||0)*parseFloat(p.value||0); s.value=isNaN(v)?'':v.toFixed(2); } }
    if(q) q.addEventListener('input',calc);
    if(p) p.addEventListener('input',calc);
})();
</script>
</body>
</html>
