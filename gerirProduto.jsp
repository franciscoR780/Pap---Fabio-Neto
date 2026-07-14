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
            String descricao  = request.getParameter("descricao");
            String categoria  = request.getParameter("categoria");
            String imagem     = request.getParameter("imagem");
            String estoqueStr = request.getParameter("estoque");
            String precoStr   = request.getParameter("preco");
            // BUG CORRIGIDO: não forçar id manualmente — BD usa AUTO_INCREMENT
            if (descricao != null && !descricao.trim().isEmpty() && estoqueStr != null && precoStr != null) {
                int    estoque = Integer.parseInt(estoqueStr);
                double preco   = Double.parseDouble(precoStr);
                if (categoria == null || categoria.trim().isEmpty()) categoria = "Geral";
                if (imagem == null) imagem = "";
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO t_produto (descricao, categoria, imagem, estoque, preco) VALUES (?,?,?,?,?)");
                ps.setString(1, descricao.trim());
                ps.setString(2, categoria.trim());
                ps.setString(3, imagem.trim());
                ps.setInt(4, estoque);
                ps.setDouble(5, preco);
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirProduto.jsp");
            return;
        }

        if ("excluir".equals(acao)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                PreparedStatement ps = conn.prepareStatement("DELETE FROM t_produto WHERE id=?");
                ps.setInt(1, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirProduto.jsp");
            return;
        }

        if ("atualizar".equals(acao)) {
            String idStr      = request.getParameter("id");
            String descricao  = request.getParameter("descricao");
            String categoria  = request.getParameter("categoria");
            String imagem     = request.getParameter("imagem");
            String estoqueStr = request.getParameter("estoque");
            String precoStr   = request.getParameter("preco");
            if (idStr != null && descricao != null && estoqueStr != null && precoStr != null) {
                int    estoque = Integer.parseInt(estoqueStr);
                double preco   = Double.parseDouble(precoStr);
                if (categoria == null || categoria.trim().isEmpty()) categoria = "Geral";
                if (imagem == null) imagem = "";
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE t_produto SET descricao=?, categoria=?, imagem=?, estoque=?, preco=? WHERE id=?");
                ps.setString(1, descricao.trim());
                ps.setString(2, categoria.trim());
                ps.setString(3, imagem.trim());
                ps.setInt(4, estoque);
                ps.setDouble(5, preco);
                ps.setInt(6, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirProduto.jsp");
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
    <title>Gerir Produtos — Hansa-Flex</title>
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
        .stock-low{color:#dc2626;font-weight:700}
        .stock-ok{color:#166534;font-weight:700}
        .img-thumb{width:40px;height:40px;object-fit:cover;border-radius:4px;vertical-align:middle}
        .hint{font-size:11px;color:#888;margin-top:-10px;margin-bottom:10px;display:block}
    </style>
</head>
<body>
<a href="painel_admin.jsp" class="back">← Voltar ao painel</a>
<h2>🔧 Gerir Produtos</h2>

<%
    Connection conn2 = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn2 = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        String editarId = request.getParameter("editar");
        int idEdit = 0, estoqueEdit = 0;
        String descricaoEdit = "", categoriaEdit = "Geral", imagemEdit = "";
        double precoEdit = 0;
        boolean modoEditar = false;

        if (editarId != null && !editarId.trim().isEmpty()) {
            PreparedStatement ps = conn2.prepareStatement("SELECT * FROM t_produto WHERE id=?");
            ps.setInt(1, Integer.parseInt(editarId));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                idEdit        = rs.getInt("id");
                descricaoEdit = rs.getString("descricao") != null ? rs.getString("descricao") : "";
                categoriaEdit = rs.getString("categoria") != null ? rs.getString("categoria") : "Geral";
                imagemEdit    = rs.getString("imagem")    != null ? rs.getString("imagem")    : "";
                estoqueEdit   = rs.getInt("estoque");
                precoEdit     = rs.getDouble("preco");
                modoEditar    = true;
            }
            rs.close(); ps.close();
        }

        /* Categorias únicas para datalist */
        java.util.List<String> categorias = new java.util.ArrayList<>();
        ResultSet rsCat = conn2.createStatement().executeQuery(
            "SELECT DISTINCT categoria FROM t_produto ORDER BY categoria");
        while (rsCat.next()) {
            String c = rsCat.getString("categoria");
            if (c != null && !c.trim().isEmpty()) categorias.add(c);
        }
        rsCat.close();
%>

<div class="form-box">
    <h3 style="color:#003d7a;margin-bottom:16px"><%= modoEditar ? "✏️ Editar Produto" : "➕ Novo Produto" %></h3>
    <form method="post" action="gerirProduto.jsp">
        <input type="hidden" name="acao" value="<%= modoEditar ? "atualizar" : "inserir" %>">
        <% if (modoEditar) { %>
            <input type="hidden" name="id" value="<%= idEdit %>">
        <% } %>
        <%-- BUG CORRIGIDO: campo ID removido do formulário de inserção — BD usa AUTO_INCREMENT --%>

        <label>Descrição *</label>
        <input type="text" name="descricao" placeholder="Descrição do produto"
               value="<%= descricaoEdit.replace("\"","&quot;") %>" required>

        <label>Categoria *</label>
        <input type="text" name="categoria" placeholder="Ex: Mangueiras, Bombas, Válvulas…"
               value="<%= categoriaEdit.replace("\"","&quot;") %>"
               list="listaCategorias" required>
        <datalist id="listaCategorias">
            <% for (String c : categorias) { %><option value="<%= c %>"><% } %>
        </datalist>
        <span class="hint">Escreva ou escolha uma categoria existente.</span>

        <label>Imagem (nome do ficheiro)</label>
        <input type="text" name="imagem" placeholder="Ex: produto1.png"
               value="<%= imagemEdit.replace("\"","&quot;") %>">
        <span class="hint">Ficheiro deve estar em <code>images/produtos/</code>. Deixe vazio para usar ícone.</span>

        <label>Estoque *</label>
        <input type="number" name="estoque" placeholder="Quantidade em estoque"
               value="<%= estoqueEdit %>" required min="0">

        <label>Preço (€) *</label>
        <input type="number" step="0.01" name="preco" placeholder="0.00"
               value="<%= precoEdit %>" required min="0">

        <button type="submit"><%= modoEditar ? "💾 Atualizar" : "➕ Adicionar" %></button>
        <% if (modoEditar) { %>
        <a href="gerirProduto.jsp" style="margin-left:10px;color:#dc3545;font-size:14px">Cancelar</a>
        <% } %>
    </form>
</div>

<table>
    <thead>
        <tr>
            <th>ID</th><th>Descrição</th><th>Categoria</th><th>Imagem</th><th>Estoque</th><th>Preço</th><th>Ações</th>
        </tr>
    </thead>
    <tbody>
<%
        Statement stmt = conn2.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM t_produto ORDER BY id");
        while (rs.next()) {
            int estoque = rs.getInt("estoque");
            String stockClass = estoque < 5 ? "stock-low" : "stock-ok";
            String imgFile = rs.getString("imagem");
%>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td style="text-align:left"><%= rs.getString("descricao") %></td>
            <td><%= rs.getString("categoria") != null ? rs.getString("categoria") : "—" %></td>
            <td>
                <% if (imgFile != null && !imgFile.trim().isEmpty()) { %>
                    <img src="../images/produtos/<%= imgFile %>" alt="img" class="img-thumb"
                         onerror="this.style.display='none';this.nextSibling.style.display='inline'">
                    <span style="display:none;font-size:11px;color:#888"><%= imgFile %></span>
                <% } else { %>
                    <span style="color:#aaa;font-size:12px">—</span>
                <% } %>
            </td>
            <td class="<%= stockClass %>"><%= estoque %></td>
            <td style="text-align:right"><%= String.format("%.2f €", rs.getDouble("preco")) %></td>
            <td>
                <a class="edit" href="gerirProduto.jsp?editar=<%= rs.getInt("id") %>">✏️ Editar</a> &nbsp;|&nbsp;
                <a class="del" href="gerirProduto.jsp?acao=excluir&id=<%= rs.getInt("id") %>"
                   onclick="return confirm('Excluir este produto?')">🗑 Excluir</a>
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
