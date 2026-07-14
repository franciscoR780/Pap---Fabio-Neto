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
            String titulo          = request.getParameter("titulo");
            String conteudo        = request.getParameter("conteudo");
            String data_publicacao = request.getParameter("data_publicacao");
            if (titulo != null && conteudo != null && data_publicacao != null) {
                // BUG CORRIGIDO: t_noticia.conteudo é VARCHAR(50) na BD — truncar para evitar erro SQL
                if (conteudo.length() > 50) conteudo = conteudo.substring(0, 50);
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO t_noticia (titulo, conteudo, data_publicacao) VALUES (?,?,?)");
                ps.setString(1, titulo.trim());
                ps.setString(2, conteudo);
                ps.setString(3, data_publicacao);
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirNoticia.jsp");
            return;
        }

        if ("excluir".equals(acao)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                PreparedStatement ps = conn.prepareStatement("DELETE FROM t_noticia WHERE id=?");
                ps.setInt(1, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirNoticia.jsp");
            return;
        }

        if ("atualizar".equals(acao)) {
            String idStr           = request.getParameter("id");
            String titulo          = request.getParameter("titulo");
            String conteudo        = request.getParameter("conteudo");
            String data_publicacao = request.getParameter("data_publicacao");
            if (idStr != null && titulo != null && conteudo != null && data_publicacao != null) {
                // BUG CORRIGIDO: truncar conteudo a 50 caracteres
                if (conteudo.length() > 50) conteudo = conteudo.substring(0, 50);
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE t_noticia SET titulo=?, conteudo=?, data_publicacao=? WHERE id=?");
                ps.setString(1, titulo.trim());
                ps.setString(2, conteudo);
                ps.setString(3, data_publicacao);
                ps.setInt(4, Integer.parseInt(idStr));
                ps.executeUpdate();
                ps.close();
            }
            conn.close();
            response.sendRedirect("gerirNoticia.jsp");
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
    <title>Gerir Notícias — Hansa-Flex</title>
    <style>
        body{font-family:Arial;padding:40px;background:#f4f4f4}
        h2{color:#003d7a;margin-bottom:20px}
        .form-box{background:white;padding:24px;border-radius:8px;margin-bottom:30px;box-shadow:0 2px 8px rgba(0,0,0,0.08);max-width:600px}
        label{display:block;font-weight:600;color:#003d7a;margin-bottom:4px;font-size:13px}
        input,textarea{padding:8px 10px;margin-bottom:14px;width:100%;border:1px solid #ccc;border-radius:5px;font-size:14px;box-sizing:border-box}
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
        .warn{background:#fef9c3;border:1px solid #fde047;color:#854d0e;padding:10px 14px;border-radius:6px;font-size:13px;margin-bottom:16px}
        .char-counter{font-size:11px;color:#888;margin-top:-10px;margin-bottom:10px;display:block}
        .char-over{color:#dc2626;font-weight:700}
    </style>
</head>
<body>
<a href="painel_admin.jsp" class="back">← Voltar ao painel</a>
<h2>📰 Gerir Notícias</h2>

<div class="warn">
    ⚠️ <strong>Atenção:</strong> O campo "Conteúdo" está limitado a <strong>50 caracteres</strong> na base de dados.
    O texto será truncado automaticamente se ultrapassar esse limite.
    Para remover esta limitação, execute: <code>ALTER TABLE t_noticia MODIFY conteudo TEXT;</code>
</div>

<%
    Connection conn2 = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn2 = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        String editarId = request.getParameter("editar");
        int idEdit = 0;
        String tituloEdit = "", conteudoEdit = "", dataPublicacaoEdit = "";
        boolean modoEditar = false;

        if (editarId != null && !editarId.trim().isEmpty()) {
            PreparedStatement ps = conn2.prepareStatement("SELECT * FROM t_noticia WHERE id=?");
            ps.setInt(1, Integer.parseInt(editarId));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                idEdit             = rs.getInt("id");
                tituloEdit         = rs.getString("titulo")          != null ? rs.getString("titulo")          : "";
                conteudoEdit       = rs.getString("conteudo")        != null ? rs.getString("conteudo")        : "";
                dataPublicacaoEdit = rs.getString("data_publicacao") != null ? rs.getString("data_publicacao") : "";
                modoEditar         = true;
            }
            rs.close(); ps.close();
        }
%>

<div class="form-box">
    <h3 style="color:#003d7a;margin-bottom:16px"><%= modoEditar ? "✏️ Editar Notícia" : "➕ Nova Notícia" %></h3>
    <form method="post" action="gerirNoticia.jsp">
        <input type="hidden" name="acao" value="<%= modoEditar ? "atualizar" : "inserir" %>">
        <% if (modoEditar) { %><input type="hidden" name="id" value="<%= idEdit %>"><% } %>

        <label>Título</label>
        <input type="text" name="titulo" placeholder="Título da notícia"
               value="<%= tituloEdit.replace("\"","&quot;") %>" required>

        <label>Conteúdo <span style="font-weight:400;color:#888">(máx. 50 caracteres)</span></label>
        <textarea name="conteudo" id="conteudo" placeholder="Resumo breve da notícia"
                  maxlength="50" required><%= conteudoEdit %></textarea>
        <span class="char-counter" id="charCount"><%= conteudoEdit.length() %>/50 caracteres</span>

        <label>Data de Publicação</label>
        <input type="date" name="data_publicacao" value="<%= dataPublicacaoEdit %>" required>

        <button type="submit"><%= modoEditar ? "💾 Atualizar" : "➕ Adicionar" %></button>
        <% if (modoEditar) { %>
        <a href="gerirNoticia.jsp" style="margin-left:10px;color:#dc3545;font-size:14px">Cancelar</a>
        <% } %>
    </form>
</div>

<table>
    <thead>
        <tr>
            <th>ID</th><th>Título</th><th>Conteúdo</th><th>Data Publicação</th><th>Ações</th>
        </tr>
    </thead>
    <tbody>
<%
        Statement stmt = conn2.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM t_noticia ORDER BY data_publicacao DESC");
        while (rs.next()) {
%>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td style="text-align:left"><%= rs.getString("titulo") %></td>
            <td style="text-align:left;font-size:12px;max-width:250px"><%= rs.getString("conteudo") %></td>
            <td><%= rs.getString("data_publicacao") %></td>
            <td>
                <a class="edit" href="gerirNoticia.jsp?editar=<%= rs.getInt("id") %>">✏️ Editar</a> &nbsp;|&nbsp;
                <a class="del" href="gerirNoticia.jsp?acao=excluir&id=<%= rs.getInt("id") %>"
                   onclick="return confirm('Excluir esta notícia?')">🗑 Excluir</a>
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
    var ta = document.getElementById('conteudo');
    var cc = document.getElementById('charCount');
    if (ta && cc) {
        ta.addEventListener('input', function() {
            var len = ta.value.length;
            cc.textContent = len + '/50 caracteres';
            cc.className = len >= 50 ? 'char-counter char-over' : 'char-counter';
        });
    }
</script>
</body>
</html>
