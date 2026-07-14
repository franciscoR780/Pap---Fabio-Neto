<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    /* Remove TODOS os atributos de sessão do admin */
    session.removeAttribute("adm_id");
    session.removeAttribute("adm_nome");
    session.removeAttribute("adm_tipo");
    session.removeAttribute("admin_logado");
    session.removeAttribute("tipoUtilizador");
    response.sendRedirect("login_admin.jsp");
%>
