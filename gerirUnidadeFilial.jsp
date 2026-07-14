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
            String nome     = request.getParameter("nome");
            String cidade   = request.getParameter("cidade");
            String telefone = request.getParameter("telefone");
            String idNotStr = request.getParameter("id_noticia");
            // BUG CORRIGIDO: id_noticia é opcional — pode não existir notícia associada
            if (nome != null && !nome.trim().isEmpty() && cidade != null && telefone != null) {
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO t_unidade_filial (nome, cidade, telefone, id_noticia) VALUES (?,?,?,?)");
                ps.setString(1, nome.trim());
                ps.setString(2, cidade.trim());
                ps.setString(3, telefone.trim());
                if (idNotStr != null && !idNotStr.trim().isEmpty()) {
                    ps.setInt(4, Integer.parseInt(idNotStr));
                } else {
                    ps.setNull(4, java.sql.Types.INTEGER);
                }
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirUnidadeFilial.jsp");
            return;
        }

        if ("excluir".equals(acao)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                PreparedStatement ps = conn.prepareStatement("DELETE FROM t_unidade_filial WHERE id=?");
                ps.setInt(1, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirUnidadeFilial.jsp");
            return;
        }

        if ("atualizar".equals(acao)) {
            String idStr    = request.getParameter("id");
            String nome     = request.getParameter("nome");
            String cidade   = request.getParameter("cidade");
            String telefone = request.getParameter("telefone");
            String idNotStr = request.getParameter("id_noticia");
            if (idStr != null && nome != null && cidade != null && telefone != null) {
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE t_unidade_filial SET nome=?, cidade=?, telefone=?, id_noticia=? WHERE id=?");
                ps.setString(1, nome.trim());
                ps.setString(2, cidade.trim());
                ps.setString(3, telefone.trim());
                if (idNotStr != null && !idNotStr.trim().isEmpty()) {
                    ps.setInt(4, Integer.parseInt(idNotStr));
                } else {
                    ps.setNull(4, java.sql.Types.INTEGER);
                }
                ps.setInt(5, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirUnidadeFilial.jsp");
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
    <title>Gerir Unidades/Filiais — Hansa-Flex</title>
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
<h2>🏢 Gerir Unidades / Filiais</h2>

<%
    Connection conn2 = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn2 = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        String editarId = request.getParameter("editar");
        int idEdit = 0, idNoticiaEdit = 0;
        String nomeEdit = "", cidadeEdit = "", telefoneEdit = "";
        boolean modoEditar = false;

        if (editarId != null && !editarId.trim().isEmpty()) {
            PreparedStatement ps = conn2.prepareStatement("SELECT * FROM t_unidade_filial WHERE id=?");
            ps.setInt(1, Integer.parseInt(editarId));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                idEdit        = rs.getInt("id");
                nomeEdit      = rs.getString("nome")     != null ? rs.getString("nome")     : "";
                cidadeEdit    = rs.getString("cidade")   != null ? rs.getString("cidade")   : "";
                telefoneEdit  = rs.getString("telefone") != null ? rs.getString("telefone") : "";
                idNoticiaEdit = rs.getInt("id_noticia"); // 0 se NULL
                modoEditar    = true;
            }
            rs.close(); ps.close();
        }
%>

<div class="form-box">
    <h3 style="color:#003d7a;margin-bottom:16px"><%= modoEditar ? "✏️ Editar Filial" : "➕ Nova Filial" %></h3>
    <form method="post" action="gerirUnidadeFilial.jsp">
        <input type="hidden" name="acao" value="<%= modoEditar ? "atualizar" : "inserir" %>">
        <% if (modoEditar) { %><input type="hidden" name="id" value="<%= idEdit %>"><% } %>

        <label>Nome da Filial *</label>
        <input type="text" name="nome" placeholder="Ex: Hansa-Flex Lisboa Centro"
               value="<%= nomeEdit.replace("\"","&quot;") %>" required>

        <label>Cidade *</label>
        <input type="text" name="cidade" placeholder="Ex: Lisboa"
               value="<%= cidadeEdit.replace("\"","&quot;") %>" required>

        <label>Telefone *</label>
        <input type="text" name="telefone" placeholder="9XXXXXXXX" maxlength="9"
               value="<%= telefoneEdit.replace("\"","&quot;") %>" required>

        <label>ID da Notícia associada <span style="font-weight:400;color:#888">(opcional)</span></label>
        <input type="number" name="id_noticia" placeholder="ID da notícia (deixe vazio se não aplicável)"
               value="<%= idNoticiaEdit > 0 ? idNoticiaEdit : "" %>" min="1">
        <span class="hint">BUG CORRIGIDO: Este campo é agora opcional. Deixe vazio se não houver notícia associada.</span>

        <button type="submit"><%= modoEditar ? "💾 Atualizar" : "➕ Adicionar" %></button>
        <% if (modoEditar) { %>
        <a href="gerirUnidadeFilial.jsp" style="margin-left:10px;color:#dc3545;font-size:14px">Cancelar</a>
        <% } %>
    </form>
</div>

<table>
    <thead>
        <tr>
            <th>ID</th><th>Nome</th><th>Cidade</th><th>Telefone</th><th>ID Notícia</th><th>Ações</th>
        </tr>
    </thead>
    <tbody>
<%
        Statement stmt = conn2.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM t_unidade_filial ORDER BY cidade");
        while (rs.next()) {
            int idNot = rs.getInt("id_noticia");
            String idNotDisplay = rs.wasNull() ? "—" : String.valueOf(idNot);
%>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td><%= rs.getString("nome") %></td>
            <td><%= rs.getString("cidade") %></td>
            <td><%= rs.getString("telefone") %></td>
            <td><%= idNotDisplay %></td>
            <td>
                <a class="edit" href="gerirUnidadeFilial.jsp?editar=<%= rs.getInt("id") %>">✏️ Editar</a> &nbsp;|&nbsp;
                <a class="del" href="gerirUnidadeFilial.jsp?acao=excluir&id=<%= rs.getInt("id") %>"
                   onclick="return confirm('Excluir esta filial?')">🗑 Excluir</a>
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
