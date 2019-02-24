package com.xujp.dj.auth

import groovy.transform.EqualsAndHashCode
import groovy.transform.ToString
import grails.compiler.GrailsCompileStatic

@GrailsCompileStatic
@EqualsAndHashCode(includes='authority')
@ToString(includes='authority', includeNames=true, includePackage=false)
class Role implements Serializable {

	private static final long serialVersionUID = 1

	String authority
	String name
	String columns
	String prompts
	static mapping = {
		cache true
		table  'dj_role'
	}

	static constraints = {
		authority blank: false, unique: true
		name  blank: false, unique: true
		columns nullable: true
		prompts nullable: true
	}
}
