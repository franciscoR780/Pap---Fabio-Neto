<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    /* ── PROTEÇÃO: só admins autenticados entram ── */
    Boolean adminLogado = (Boolean) session.getAttribute("admin_logado");
    if (!Boolean.TRUE.equals(adminLogado)) {
        response.sendRedirect("admin/login_admin.jsp");
        return;
    }

    String DB_URL  = "jdbc:mysql://localhost:3306/bd_pap?useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "";
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

    String acao = request.getParameter("acao");

    if ("inserir".equals(acao)) {
        int produtoId      = Integer.parseInt(request.getParameter("produto_id"));
        String nomeCliente = request.getParameter("nome_cliente");
        String emailCliente= request.getParameter("email_cliente");
        String telefone    = request.getParameter("telefone");
        String morada      = request.getParameter("morada");
        String localidade  = request.getParameter("localidade");
        String codigoPostal= request.getParameter("codigo_postal");
        String pais        = request.getParameter("pais");
        String nif         = request.getParameter("nif");
        int quantidade     = Integer.parseInt(request.getParameter("quantidade"));
        String obs         = request.getParameter("observacoes");
        String estado      = request.getParameter("estado");

        PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO t_encomenda (produto_id,nome_cliente,email_cliente,telefone,morada," +
            "localidade,codigo_postal,pais,nif,quantidade,observacoes,estado) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)");
        ps.setInt(1,produtoId); ps.setString(2,nomeCliente); ps.setString(3,emailCliente);
        ps.setString(4,telefone); ps.setString(5,morada); ps.setString(6,localidade);
        ps.setString(7,codigoPostal); ps.setString(8,pais); ps.setString(9,nif);
        ps.setInt(10,quantidade); ps.setString(11,obs); ps.setString(12,estado);
        ps.executeUpdate(); ps.close();
        response.sendRedirect("encomenda.jsp");
    }

    if ("excluir".equals(acao)) {
        int id = Integer.parseInt(request.getParameter("id"));
        PreparedStatement ps = conn.prepareStatement("DELETE FROM t_encomenda WHERE id=?");
        ps.setInt(1,id); ps.executeUpdate(); ps.close();
        response.sendRedirect("encomenda.jsp");
    }

    if ("atualizar_estado".equals(acao)) {
        int id        = Integer.parseInt(request.getParameter("id"));
        String estado = request.getParameter("estado");
        PreparedStatement ps = conn.prepareStatement("UPDATE t_encomenda SET estado=? WHERE id=?");
        ps.setString(1,estado); ps.setInt(2,id);
        ps.executeUpdate(); ps.close();
        response.sendRedirect("encomenda.jsp");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gerir Encomendas — Hansa-Flex</title>
    <style>
        body{font-family:Arial;padding:40px;background:#f4f4f4}
        h2{color:#003d7a;margin-bottom:20px}
        .form-box{background:white;padding:24px;border-radius:8px;margin-bottom:30px;box-shadow:0 2px 8px rgba(0,0,0,0.08)}
        label{display:block;font-weight:600;color:#003d7a;margin-bottom:4px;font-size:13px;margin-top:10px}
        input,select,textarea{padding:8px 10px;width:100%;border:1px solid #ccc;border-radius:5px;font-size:14px;box-sizing:border-box}
        textarea{height:60px;resize:vertical}
        .grid2{display:grid;grid-template-columns:1fr 1fr;gap:14px}
        .grid3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:14px}
        button.primary{padding:10px 22px;background:#003d7a;color:white;border:none;cursor:pointer;border-radius:5px;font-size:14px;font-weight:600;margin-top:16px}
        button.primary:hover{background:#001f3f}
        table{width:100%;border-collapse:collapse;background:white;border-radius:8px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);font-size:13px}
        th,td{border:1px solid #ddd;padding:9px 10px;text-align:center}
        th{background:#003d7a;color:white;font-size:12px}
        tr:hover{background:#f0f5ff}
        .estado-badge{display:inline-block;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700}
        .pendente{background:#fef3c7;color:#92600a} .aprovado{background:#dcfce7;color:#15803d} .cancelado{background:#fee2e2;color:#dc2626}
        a{text-decoration:none} .edit{color:#0056b3;font-weight:600} .del{color:#dc3545;font-weight:600}
        .back{display:inline-block;margin-bottom:20px;color:#003d7a;font-weight:600;text-decoration:none;font-size:14px}
        .back:hover{text-decoration:underline}
        .toggle-form{background:#003d7a;color:white;border:none;padding:9px 20px;border-radius:5px;cursor:pointer;font-size:13px;font-weight:600;margin-bottom:16px}
        #formNova{display:none}
        .summary{display:flex;gap:20px;margin-bottom:24px}
        .stat-card{background:white;padding:18px 24px;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,0.08);text-align:center;min-width:130px}
        .stat-card .num{font-size:28px;font-weight:800;color:#003d7a}
        .stat-card .lbl{font-size:12px;color:#666;margin-top:4px}
    </style>
</head>
<body>
<a href="admin/painel_admin.jsp" class="back">← Voltar ao painel</a>
<h2>📦 Gerir Encomendas</h2>

<%
    /* contadores */
    int totalEnc=0, pendentes=0, aprovadas=0;
    ResultSet rsc = conn.createStatement().executeQuery(
        "SELECT COUNT(*) t, SUM(estado='Pendente') p, SUM(estado='Aprovado') a FROM t_encomenda");
    if (rsc.next()) { totalEnc=rsc.getInt("t"); pendentes=rsc.getInt("p"); aprovadas=rsc.getInt("a"); }
    rsc.close();
%>
<div class="summary">
    <div class="stat-card"><div class="num"><%= totalEnc %></div><div class="lbl">Total</div></div>
    <div class="stat-card"><div class="num" style="color:#92600a"><%= pendentes %></div><div class="lbl">Pendentes</div></div>
    <div class="stat-card"><div class="num" style="color:#15803d"><%= aprovadas %></div><div class="lbl">Aprovadas</div></div>
</div>

<button class="toggle-form" onclick="document.getElementById('formNova').style.display=document.getElementById('formNova').style.display==='none'?'block':'none'">
    ➕ Nova Encomenda
</button>

<div id="formNova" class="form-box">
    <h3 style="color:#003d7a;margin-bottom:16px">Nova Encomenda</h3>
    <form method="post">
        <input type="hidden" name="acao" value="inserir">
        <div class="grid2">
            <div><label>ID Produto *</label><input type="number" name="produto_id" required></div>
            <div><label>Quantidade *</label><input type="number" name="quantidade" min="1" value="1" required></div>
        </div>
        <div class="grid2">
            <div><label>Nome do Cliente *</label><input type="text" name="nome_cliente" placeholder="Nome completo" required></div>
            <div><label>Email *</label><input type="email" name="email_cliente" placeholder="email@exemplo.com" required></div>
        </div>
        <div class="grid2">
            <div><label>Telefone</label><input type="text" name="telefone" placeholder="9XXXXXXXX"></div>
            <div><label>NIF</label><input type="text" name="nif" placeholder="NIF / NIPC"></div>
        </div>
        <label>Morada *</label>
        <input type="text" name="morada" placeholder="Rua, Nº" required>
        <div class="grid3">
            <div><label>Localidade *</label><input type="text" name="localidade" required></div>
            <div><label>Código Postal *</label><input type="text" name="codigo_postal" placeholder="0000-000" required></div>
            <div><label>País</label><input type="text" name="pais" value="Portugal"></div>
        </div>
        <label>Estado</label>
        <select name="estado">
            <option value="Pendente">Pendente</option>
            <option value="Aprovado">Aprovado</option>
            <option value="Cancelado">Cancelado</option>
        </select>
        <label>Observações</label>
        <textarea name="observacoes" placeholder="Notas adicionais..."></textarea>
        <button type="submit" class="primary">➕ Criar Encomenda</button>
    </form>
</div>

<table>
    <tr>
        <th>ID</th><th>Produto</th><th>Cliente</th><th>Email</th><th>Telefone</th>
        <th>Localidade</th><th>Qtd</th><th>Data</th><th>Estado</th><th>Ações</th>
    </tr>
<%
    Statement stmt = conn.createStatement();
    ResultSet rs   = stmt.executeQuery(
        "SELECT e.*, p.descricao AS prod_nome FROM t_encomenda e " +
        "LEFT JOIN t_produto p ON e.produto_id=p.id ORDER BY e.id DESC");
    while (rs.next()) {
        String est = rs.getString("estado");
        if (est == null) est = "Pendente";
        String cls = est.equalsIgnoreCase("Pendente") ? "pendente"
                   : est.equalsIgnoreCase("Aprovado")  ? "aprovado" : "cancelado";
%>
    <tr>
        <td><%= rs.getInt("id") %></td>
        <td style="text-align:left;font-size:12px"><%= rs.getString("prod_nome") != null ? rs.getString("prod_nome") : "ID:"+rs.getInt("produto_id") %></td>
        <td><%= rs.getString("nome_cliente") %></td>
        <td style="font-size:12px"><%= rs.getString("email_cliente") %></td>
        <td><%= rs.getString("telefone") %></td>
        <td><%= rs.getString("localidade") %></td>
        <td><%= rs.getInt("quantidade") %></td>
        <td style="font-size:11px"><%= rs.getString("data_encomenda") != null ? rs.getString("data_encomenda").substring(0,10) : "-" %></td>
        <td><span class="estado-badge <%= cls %>"><%= est %></span></td>
        <td>
            <form method="post" style="display:inline">
                <input type="hidden" name="acao" value="atualizar_estado">
                <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                <select name="estado" onchange="this.form.submit()" style="font-size:11px;padding:2px 4px;width:auto">
                    <option value="Pendente"  <%= "Pendente".equalsIgnoreCase(est)  ? "selected" : "" %>>Pendente</option>
                    <option value="Aprovado"  <%= "Aprovado".equalsIgnoreCase(est)  ? "selected" : "" %>>Aprovado</option>
                    <option value="Cancelado" <%= "Cancelado".equalsIgnoreCase(est) ? "selected" : "" %>>Cancelado</option>
                </select>
            </form>
            &nbsp;
            <a class="del" href="encomenda.jsp?acao=excluir&id=<%= rs.getInt("id") %>"
               onclick="return confirm('Eliminar esta encomenda?')">🗑</a>
        </td>
    </tr>
<%
    }
    rs.close(); stmt.close(); conn.close();
%>
</table>
</body>
</html>
