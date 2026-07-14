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
            String prodIdStr   = request.getParameter("produto_id");
            String nomeCliente = request.getParameter("nome_cliente");
            String emailCliente= request.getParameter("email_cliente");
            String telefone    = request.getParameter("telefone");
            String morada      = request.getParameter("morada");
            String localidade  = request.getParameter("localidade");
            String codPostal   = request.getParameter("codigo_postal");
            String pais        = request.getParameter("pais");
            String nif         = request.getParameter("nif");
            String qtdStr      = request.getParameter("quantidade");
            String obs         = request.getParameter("observacoes");
            String estado      = request.getParameter("estado");
            if (prodIdStr != null && nomeCliente != null && qtdStr != null) {
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO t_encomenda (produto_id,nome_cliente,email_cliente,telefone,morada," +
                    "localidade,codigo_postal,pais,nif,quantidade,observacoes,estado) " +
                    "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)");
                ps.setInt(1, Integer.parseInt(prodIdStr));
                ps.setString(2, nomeCliente);
                ps.setString(3, emailCliente != null ? emailCliente : "");
                ps.setString(4, telefone     != null ? telefone     : "");
                ps.setString(5, morada       != null ? morada       : "");
                ps.setString(6, localidade   != null ? localidade   : "");
                ps.setString(7, codPostal    != null ? codPostal    : "");
                ps.setString(8, pais         != null ? pais         : "Portugal");
                ps.setString(9, nif          != null ? nif          : "");
                ps.setInt(10, Integer.parseInt(qtdStr));
                ps.setString(11, obs         != null ? obs          : "");
                ps.setString(12, estado      != null ? estado       : "Pendente");
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirEncomenda.jsp");
            return;
        }

        if ("excluir".equals(acao)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                PreparedStatement ps = conn.prepareStatement("DELETE FROM t_encomenda WHERE id=?");
                ps.setInt(1, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirEncomenda.jsp");
            return;
        }

        if ("atualizar".equals(acao)) {
            String idStr       = request.getParameter("id");
            String prodIdStr   = request.getParameter("produto_id");
            String nomeCliente = request.getParameter("nome_cliente");
            String emailCliente= request.getParameter("email_cliente");
            String telefone    = request.getParameter("telefone");
            String morada      = request.getParameter("morada");
            String localidade  = request.getParameter("localidade");
            String codPostal   = request.getParameter("codigo_postal");
            String pais        = request.getParameter("pais");
            String nif         = request.getParameter("nif");
            String qtdStr      = request.getParameter("quantidade");
            String obs         = request.getParameter("observacoes");
            String estado      = request.getParameter("estado");
            if (idStr != null && prodIdStr != null && nomeCliente != null && qtdStr != null) {
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE t_encomenda SET produto_id=?,nome_cliente=?,email_cliente=?,telefone=?," +
                    "morada=?,localidade=?,codigo_postal=?,pais=?,nif=?,quantidade=?,observacoes=?,estado=? WHERE id=?");
                ps.setInt(1, Integer.parseInt(prodIdStr));
                ps.setString(2, nomeCliente);
                ps.setString(3, emailCliente != null ? emailCliente : "");
                ps.setString(4, telefone     != null ? telefone     : "");
                ps.setString(5, morada       != null ? morada       : "");
                ps.setString(6, localidade   != null ? localidade   : "");
                ps.setString(7, codPostal    != null ? codPostal    : "");
                ps.setString(8, pais         != null ? pais         : "Portugal");
                ps.setString(9, nif          != null ? nif          : "");
                ps.setInt(10, Integer.parseInt(qtdStr));
                ps.setString(11, obs         != null ? obs          : "");
                ps.setString(12, estado      != null ? estado       : "Pendente");
                ps.setInt(13, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirEncomenda.jsp");
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
    <title>Gerir Encomendas — Hansa-Flex</title>
    <style>
        body{font-family:Arial;padding:40px;background:#f4f4f4}
        h2{color:#003d7a;margin-bottom:20px}
        .form-box{background:white;padding:24px;border-radius:8px;margin-bottom:30px;box-shadow:0 2px 8px rgba(0,0,0,0.08);max-width:700px}
        label{display:block;font-weight:600;color:#003d7a;margin-bottom:4px;font-size:13px}
        input,select,textarea{padding:8px 10px;margin-bottom:14px;width:100%;border:1px solid #ccc;border-radius:5px;font-size:14px;box-sizing:border-box}
        textarea{height:60px;resize:vertical}
        .grid2{display:grid;grid-template-columns:1fr 1fr;gap:14px}
        .grid3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:14px}
        button{padding:8px 18px;background:#003d7a;color:white;border:none;cursor:pointer;border-radius:5px;font-size:14px;font-weight:600}
        button:hover{background:#001f3f}
        table{width:100%;border-collapse:collapse;background:white;border-radius:8px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)}
        th,td{border:1px solid #ddd;padding:10px;text-align:center;font-size:13px}
        th{background:#003d7a;color:white;font-size:12px}
        tr:hover{background:#f0f5ff}
        a{text-decoration:none} .edit{color:#0056b3;font-weight:600} .del{color:#dc3545;font-weight:600}
        .back{display:inline-block;margin-bottom:20px;color:#003d7a;font-weight:600;text-decoration:none;font-size:14px}
        .back:hover{text-decoration:underline}
        .alert-err{background:#fee2e2;color:#dc2626;padding:10px 16px;border-radius:6px;margin-bottom:16px;font-weight:600}
        .badge{display:inline-block;padding:3px 10px;border-radius:12px;font-size:12px;font-weight:600}
        .badge-pendente{background:#fef3c7;color:#92400e}
        .badge-aprovado{background:#dcfce7;color:#166534}
        .badge-cancelado{background:#fee2e2;color:#991b1b}
        .summary{display:flex;gap:16px;margin-bottom:24px;flex-wrap:wrap}
        .stat-card{background:white;padding:16px 22px;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,0.08);text-align:center;min-width:120px}
        .stat-card .num{font-size:26px;font-weight:800;color:#003d7a}
        .stat-card .lbl{font-size:12px;color:#666;margin-top:4px}
    </style>
</head>
<body>
<a href="painel_admin.jsp" class="back">← Voltar ao painel</a>
<h2>📬 Gerir Encomendas</h2>

<%
    Connection conn2 = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn2 = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        int totalEnc=0, pendentes=0, aprovadas=0, canceladas=0;
        ResultSet rsc = conn2.createStatement().executeQuery(
            "SELECT COUNT(*) t, " +
            "SUM(LOWER(estado)='pendente') p, " +
            "SUM(LOWER(estado)='aprovado') a, " +
            "SUM(LOWER(estado)='cancelado') c FROM t_encomenda");
        if (rsc.next()) {
            totalEnc   = rsc.getInt("t");
            pendentes  = rsc.getInt("p");
            aprovadas  = rsc.getInt("a");
            canceladas = rsc.getInt("c");
        }
        rsc.close();
%>

<div class="summary">
    <div class="stat-card"><div class="num"><%= totalEnc %></div><div class="lbl">Total</div></div>
    <div class="stat-card"><div class="num" style="color:#92400e"><%= pendentes %></div><div class="lbl">Pendentes</div></div>
    <div class="stat-card"><div class="num" style="color:#166534"><%= aprovadas %></div><div class="lbl">Aprovadas</div></div>
    <div class="stat-card"><div class="num" style="color:#991b1b"><%= canceladas %></div><div class="lbl">Canceladas</div></div>
</div>

<%
        String editarId = request.getParameter("editar");
        int    idEdit = 0, prodIdEdit = 0, qtdEdit = 1;
        String nomeEdit="", emailEdit="", telEdit="", moradaEdit="", localEdit="",
               cpEdit="", paisEdit="Portugal", nifEdit="", obsEdit="", estadoEdit="Pendente";
        boolean modoEditar = false;

        if (editarId != null && !editarId.trim().isEmpty()) {
            PreparedStatement ps = conn2.prepareStatement("SELECT * FROM t_encomenda WHERE id=?");
            ps.setInt(1, Integer.parseInt(editarId));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                idEdit     = rs.getInt("id");
                prodIdEdit = rs.getInt("produto_id");
                nomeEdit   = rs.getString("nome_cliente")  != null ? rs.getString("nome_cliente")  : "";
                emailEdit  = rs.getString("email_cliente") != null ? rs.getString("email_cliente") : "";
                telEdit    = rs.getString("telefone")      != null ? rs.getString("telefone")      : "";
                moradaEdit = rs.getString("morada")        != null ? rs.getString("morada")        : "";
                localEdit  = rs.getString("localidade")    != null ? rs.getString("localidade")    : "";
                cpEdit     = rs.getString("codigo_postal") != null ? rs.getString("codigo_postal") : "";
                paisEdit   = rs.getString("pais")          != null ? rs.getString("pais")          : "Portugal";
                nifEdit    = rs.getString("nif")           != null ? rs.getString("nif")           : "";
                qtdEdit    = rs.getInt("quantidade");
                obsEdit    = rs.getString("observacoes")   != null ? rs.getString("observacoes")   : "";
                estadoEdit = rs.getString("estado")        != null ? rs.getString("estado")        : "Pendente";
                modoEditar = true;
            }
            rs.close(); ps.close();
        }
%>

<div class="form-box">
    <h3 style="color:#003d7a;margin-bottom:16px"><%= modoEditar ? "✏️ Editar Encomenda" : "➕ Nova Encomenda" %></h3>
    <form method="post" action="gerirEncomenda.jsp">
        <input type="hidden" name="acao" value="<%= modoEditar ? "atualizar" : "inserir" %>">
        <% if (modoEditar) { %><input type="hidden" name="id" value="<%= idEdit %>"><% } %>

        <div class="grid2">
            <div><label>ID Produto *</label><input type="number" name="produto_id" value="<%= prodIdEdit %>" required min="1"></div>
            <div><label>Quantidade *</label><input type="number" name="quantidade" value="<%= qtdEdit %>" required min="1"></div>
        </div>
        <div class="grid2">
            <div><label>Nome do Cliente *</label><input type="text" name="nome_cliente" placeholder="Nome completo" value="<%= nomeEdit.replace("\"","&quot;") %>" required></div>
            <div><label>Email</label><input type="email" name="email_cliente" placeholder="email@exemplo.com" value="<%= emailEdit.replace("\"","&quot;") %>"></div>
        </div>
        <div class="grid2">
            <div><label>Telefone</label><input type="text" name="telefone" placeholder="9XXXXXXXX" value="<%= telEdit.replace("\"","&quot;") %>"></div>
            <div><label>NIF</label><input type="text" name="nif" placeholder="NIF / NIPC" value="<%= nifEdit.replace("\"","&quot;") %>"></div>
        </div>
        <label>Morada</label>
        <input type="text" name="morada" placeholder="Rua, Nº" value="<%= moradaEdit.replace("\"","&quot;") %>">
        <div class="grid3">
            <div><label>Localidade</label><input type="text" name="localidade" value="<%= localEdit.replace("\"","&quot;") %>"></div>
            <div><label>Código Postal</label><input type="text" name="codigo_postal" placeholder="0000-000" value="<%= cpEdit.replace("\"","&quot;") %>"></div>
            <div><label>País</label><input type="text" name="pais" value="<%= paisEdit.replace("\"","&quot;") %>"></div>
        </div>
        <label>Estado</label>
        <select name="estado">
            <option value="Pendente"  <%= "Pendente".equalsIgnoreCase(estadoEdit)  ? "selected" : "" %>>Pendente</option>
            <option value="Aprovado"  <%= "Aprovado".equalsIgnoreCase(estadoEdit)  ? "selected" : "" %>>Aprovado</option>
            <option value="Cancelado" <%= "Cancelado".equalsIgnoreCase(estadoEdit) ? "selected" : "" %>>Cancelado</option>
        </select>
        <label>Observações</label>
        <textarea name="observacoes" placeholder="Notas adicionais..."><%= obsEdit %></textarea>

        <button type="submit"><%= modoEditar ? "💾 Atualizar" : "➕ Adicionar" %></button>
        <% if (modoEditar) { %>
        <a href="gerirEncomenda.jsp" style="margin-left:10px;color:#dc3545;font-size:14px">Cancelar</a>
        <% } %>
    </form>
</div>

<table>
    <thead>
        <tr>
            <th>ID</th><th>Produto</th><th>Cliente</th><th>Email</th><th>Telefone</th>
            <th>Localidade</th><th>Qtd</th><th>Data</th><th>Estado</th><th>Ações</th>
        </tr>
    </thead>
    <tbody>
<%
        Statement stmt = conn2.createStatement();
        ResultSet rs = stmt.executeQuery(
            "SELECT e.*, p.descricao AS prod_nome FROM t_encomenda e " +
            "LEFT JOIN t_produto p ON e.produto_id=p.id ORDER BY e.id DESC");
        while (rs.next()) {
            String est = rs.getString("estado");
            if (est == null) est = "Pendente";
            String badgeClass = est.equalsIgnoreCase("Aprovado")  ? "badge-aprovado"
                              : est.equalsIgnoreCase("Cancelado") ? "badge-cancelado"
                              : "badge-pendente";
            String prodNome = rs.getString("prod_nome");
            if (prodNome == null) prodNome = "ID: " + rs.getInt("produto_id");
            String dataEnc = rs.getString("data_encomenda");
            if (dataEnc != null && dataEnc.length() >= 10) dataEnc = dataEnc.substring(0, 10);
            else if (dataEnc == null) dataEnc = "-";
%>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td style="text-align:left;font-size:12px"><%= prodNome %></td>
            <td><%= rs.getString("nome_cliente") %></td>
            <td style="font-size:12px"><%= rs.getString("email_cliente") %></td>
            <td><%= rs.getString("telefone") != null ? rs.getString("telefone") : "—" %></td>
            <td><%= rs.getString("localidade") %></td>
            <td><%= rs.getInt("quantidade") %></td>
            <td style="font-size:11px"><%= dataEnc %></td>
            <td><span class="badge <%= badgeClass %>"><%= est %></span></td>
            <td>
                <a class="edit" href="gerirEncomenda.jsp?editar=<%= rs.getInt("id") %>">✏️ Editar</a> &nbsp;|&nbsp;
                <a class="del" href="gerirEncomenda.jsp?acao=excluir&id=<%= rs.getInt("id") %>"
                   onclick="return confirm('Eliminar esta encomenda?')">🗑 Excluir</a>
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
