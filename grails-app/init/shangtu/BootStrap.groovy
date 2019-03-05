package shangtu

import grails.plugin.springsecurity.SpringSecurityService


class BootStrap {
    SpringSecurityService springSecurityService
    def init = { servletContext ->
    }
    def destroy = {
    }
}
