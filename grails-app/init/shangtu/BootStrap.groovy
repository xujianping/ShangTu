package shangtu

import com.xujp.dj.auth.RequestMap
import com.xujp.dj.auth.User
import grails.plugin.springsecurity.SpringSecurityService
import grails.plugin.springsecurity.SpringSecurityUtils


class BootStrap {
    SpringSecurityService springSecurityService
    def init = { servletContext ->
//        for (String url in [
//                '/', '/error', '/index', '/index.gsp', '/**/favicon.ico', '/shutdown',
//                '/assets/**', '/**/js/**', '/**/css/**', '/**/images/**',
//                '/login', '/login.*', '/login/*',
//                '/logout', '/logout.*', '/logout/*']) {
//            new RequestMap(url: url, configAttribute: 'permitAll').save()
//        }
//        new RequestMap(url: '/book/**',      configAttribute: 'ROLE_ADMIN').save()

    }
    def destroy = {
    }
}
