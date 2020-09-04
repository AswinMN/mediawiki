# MediaWiki Helm Chart

## INSTALLATION

If you're planning on migrating a MediaWiki instance to Kubernetes from
another source, see the [#migration](#migration) section below.

We currently don't have a public HTTP repository for Helm charts, so
installation can only be done from the local filesystem. Here are the
instructions on how to do that:

1. Clone the MediaWiki Helm Chart repository:

```bash
[~]$ git clone https://gitlab.triumf.ca/k8s/helm/mediawiki
```

2. Enter the cloned MediaWiki directory and edit/create/add values for
your own install:

```bash
[~]$ cd mediawiki
[~/mediawiki]$ vim new-values.yml # Edit values in here
```

3. If you intend on using an existing TLS certificate for your ingress point,
you'll have to add the TLS secret manually to Kubernetes. The [Kubernetes Let's Encrypt](https://gitlab.triumf.ca/docs/kubernetes/blob/master/kubernetes-letsencrypt.md)
documentation should help with that. Once you have your secret object that
contains the TLS certificate you want, just add the secretName value and
host values to the ingress.tls fields your custom values.yaml.

4. Deploy your MediaWiki instance with Helm:

```bash
[~/mediawiki]$ helm upgrade --install --namespace=my-wiki my-wiki -f new-values.yaml .
```

That should be it!

In a minute or so, you should be able to make HTTP requests from the host
and path of your new wiki.

## Configuration

There are many different configuration options for this chart, so the
configuration section is broken down into a "general" section, for general
options not specific to MediaWiki, a "main" section, consisting of the
options available for vanilla MediaWiki installs, and finally an "extensions"
section that lists the options available to each available extension. In some
cases, an extension makes use of a value available in the "main" MediaWiki
section. In those cases, they will be noted in the extension category, but
should be added to the appropriate main MediaWiki value. The appropriate value
should be noted in each section, when applicable.

### General Options

Parameter | Description | Default
--------- | ----------- | -------
imageTag  | Official MediaWiki Docker release image tag | `1.31`
gitToken  | Token to use when cloning static content from git repo (will soon be deprecated) | `nil`
replicas  | The number of MediaWiki deployment replicas | `1`
rootDir   | The root path of MediaWiki inside the container - This should never be changed and will likely be discontinued as a configurable option | `/var/www/html`
ingress.enabled | Enable an Ingress resource for MediaWiki | `false`
ingress.hosts | This is an array consisting of hostname + secretName entries per array element (see the next 2 config values) | `[]`
ingress.hosts[\*].hostname | A valid ingress hostname for the MediaWiki Site | `nil`
ingress.hosts[\*].secretName | If using TLS certificates, secretName provides the name of the secret that holds the TLS certificate information | `nil`
ingress.tls | A boolean flag to enable/disable TLS termination for incoming traffic | `false`
letsEncrypt.enabled | A boolean flag to enable/disable automatic Let's Encrypt certificate retrieval (requires [cert-manager](https://github.com/helm/charts/tree/master/stable/cert-manager)) | `false`
letsEncrypt.issuer | Determines the Let's Encrypt issuer to use for retrieving the site certificate(s) | `nil`
backups.enabled | Enable database backups on every restart (see [backups](#backups) for what this is used for) | `false`
backups.size | The size of the backups volume | `8Gi`
backups.storageClass | The storage class from which we want to request a permanent volume | `nil`
backups.www.enabled | Enable HTTP access to the backup partition | `false`
backups.www.authType | Use authType (basic or LDAP) to authenticate to the backup path | `basic`
backups.www.authName | Use authName as the authentication realm name | `Wiki Backups`
backups.www.basic.password | Sets the password for the "backups" user if backups.www.authType is set to "basic" | `nil`
backups.www.ldap.requireGroups | A list of required groups in LDAP for users authenticating to the backup section | `[]`
backups.www.ldap.requireValidUser | Add "Require valid-user" directive to Apache config. This will effectively give all authenticated users access. If you only wish to grant access to specific groups of people, set this to `false` and use the backups.www.ldap.requireGroups option instead | `false`
backups.www.ldap.baseDN | Base DN to use when accessing LDAP | `nil`
backups.www.ldap.userID | The user ID field used when checking the user against LDAP | `uid`
backups.www.ldap.objectClass | The LDAP objectClass search field to use for searching users | `(objectClass=person)`
backups.www.ldap.servers | A list of LDAP servers to validate against | `[]`
persistence.enabled | Enable persistent storage for static content | `false`
persistence.size | The size of the persistent storage volume | `1Gi`
persistence.storageClass | The storage class from which we want to request a permanent volume | `nil`
persistence.accessModes | An array of Access Modes to use for accessing storage | `[ReadWriteOnce]`
migration.host | The source host to migrate from (see [migration](#migration) section for more details) | `nil`
migration.port | The source port to migrate from (see [migration](#migration) section for more details) | `nil`
debugging | Enable debugging. This sets $wgShowExceptionDetails, $wgShowDBErrorBacktrace and $wgShowSQLErrors to true | `false`

### Main Options

Parameter | Description | Default
--------- | ----------- | -------
mediawiki.admin | The Wiki admin username | `admin`
mediawiki.adminPassword | The Wiki admin user password | `abc123`
mediawiki.rootDir | The root path of MediaWiki inside the container - This should never be changed and will likely be discontinued as a configurable option | `/var/www/html`
mediawiki.wgScriptPath | The MediaWiki $wgScriptPath value | `"/"`
mediawiki.wgLanguageCode | The MediaWiki $wgLanguageCode value | `en`
mediawiki.wgEmergencyContact | The MediaWiki $wgEmergencyContact value | `emergency@site.com`
mediawiki.wgPasswordSender | The MediaWiki $wgPasswordSender value | `no-reply@site.com`
mediawiki.wgDBAdminUser | The $wgDBAdminUser (database root username) | `root`
mediawiki.wgDBAdminPassword | The $wgDBAdminPassword (database root user password) | `nil`
mediawiki.wgDBType | The $wgDBType value | `mysql`
mediawiki.wgDBName | The $wgDBName value | `wiki`
mediawiki.wgDBPort | The $wgDBPort value | `3306`
mediawiki.wgDBUser | The $wgDBUser value | `mediawiki`
mediawiki.wgDBPassword | The $wgDBPassword value | `nil`
mediawiki.wgDBPrefix | The $wgDBPrefix value | `wiki_`
mediawiki.wgSitename | The $wgSitename value | `"Wiki Site"`
mediawiki.wgDBServers | An array of database server names (see $wgDBServers) | `[]`
mediawiki.wgEnableUploads | The $wgEnableUploads value | `false`

### Extension Options

#### Approved Revs

Extension Website: https://www.mediawiki.org/wiki/Extension:Approved_Revs

Parameter | Description | Default
--------- | ----------- | -------
mediawiki.extensions.approvedRevs.enabled   | Enable/disable this extension | `false`
mediawiki.extensions.approvedRevs.egApprovedRevsAutomaticApprovals   | Enable/disable automatic approvals | `false`
mediawiki.extensions.approvedRevs.egApprovedRevsShowApproveLatest | Include links with no approved revision on the "Special:ApprovedRevs" page | `true`
mediawiki.extensions.approvedRevs.egApprovedRevsBlankIfUnapproved | If you want to, you can have pages that have no approved revision show up as blank - users will still be able to see all the revisions if they click on the "history" tab, but the main display will be a blank page | `true`
mediawiki.extensions.approvedRevs.egApprovedRevsShowNotApprovedMessage | By default, pages with no approved revision simply show up normally, with no indication of their status. You can have such pages display a message at the top saying, "This is the latest revision of this page; it has no approved revision." | `true`
mediawiki.extensions.approvedRevs.egApprovedRevsNamespaces | Array of namespaces that are handled by the extension | `[NS_MAIN, NS_USER, NS_TEMPLATE, NS_HELP, NS_PROJECT]`
mediawiki.extensions.approvedRevs.egApprovedRevsSelfOwnedNamespaces | Allow non-admins to approve pages in the provided list of namespaces | `[]`
mediawiki.wgGroupPermissions | This value is not specific to the ApprovedRevs extension, but ApprovedRevs uses it by adding the following user rights:<br/>\* approverevisions - approve and unapprove revisions of pages<br/>\*viewlinktolatest - see a note at the top of pages that have an approved revision, explaining that what<br/>the user is seeing is not necessarily the latest revision.<br/>\*viewapprover - see another note at the top of pages that have an approved revision, stating who last approved it| \*approvedrevisions: all members of sysop<br/>\* viewlinktolatest: everyone</br>\* viewapprover: all members of sysop |

#### Bread Crumbs 2

https://www.mediawiki.org/wiki/Extension:BreadCrumbs2

Parameter | Description | Default
--------- | ----------- | -------
mediawiki.extensions.breadCrumbs2.enabled   | Enable/disable this extension | `false`

#### Category Tree

Extension Website: https://www.mediawiki.org/wiki/Extension:CategoryTree

Parameter | Description | Default
--------- | ----------- | -------
mediawiki.extensions.categoryTree.enabled   | Enable/disable this extension | `false`
mediawiki.extensions.categoryTree.wgCategoryTreeMaxChildren   | maximum number of children shown in a tree node
mediawiki.extensions.categoryTree.wgCategoryTreeAllowTag | enable &lt;categorytree&gt; tag |
mediawiki.extensions.categoryTree.wgCategoryTreeDynamicTag | loads the first level of the tree in a &lt;categorytree&gt; dynamically
mediawiki.extensions.categoryTree.wgCategoryTreeDisableCache | disables the parser cache for pages with a &lt;categorytree&gt; tag or provides max cache time in seconds
mediawiki.extensions.categoryTree.wgCategoryTreeMaxDepth | A map defining the maximum depth for each [mode](https://www.mediawiki.org/wiki/Extension:CategoryTree#Modes) | `categories: 2<br/>pages: 1<br/>all: 1<br/>parents: 1` |
mediawiki.extensions.categoryTree.wgCategoryDefaultMode | Default category mode, one of: "categories", "pages" or "all" | `categories`
mediawiki.extensions.categoryTree.wgCategoryTreeForceHeaders | forces the scripts needed by CategoryTree on every page, instead of on-demand | `false`

#### Confirm Account

Extension Website: https://www.mediawiki.org/wiki/Extension:ConfirmAccount

Parameter | Description | Default
--------- | ----------- | -------
mediawiki.extensions.confirmAccount.enabled   | Enable/disable this extension | `false`
mediawiki.extensions.confirmAccount.wgRejectedAccountMaxAge | Minimum amount of time to wait between re-requests (0 = no wait time) | `0`
mediawiki.extensions.confirmAccount.wgConfirmAccountRequestForItems | This value matches the [$wgConfirmAccountRequestFormItems](https://github.com/wikimedia/mediawiki-extensions-ConfirmAccount/blob/master/ConfirmAccount.config.php#L27) associative array in the ConfirmAccount config | `null`
mediawiki.extensions.confirmAccount.wgConfirmAccountAccount | Send an email to this address when account requestors confirm their email | `null`
mediawiki.extensions.confirmAccount.requestAccount | When enabled, adds a "Request account" login link | `false`

#### LDAP Authentication

Extension Website: https://www.mediawiki.org/wiki/Extension:LDAP_Authentication

Options should link fairly directly to the ones listed [here](https://www.mediawiki.org/wiki/Extension:LDAP_Authentication/Configuration_Options)

Parameter | Description | Default
--------- | ----------- | -------
mediawiki.extensions.ldapAuthentication.enabled | Enable LDAP Authentication extension | `false`
mediawiki.extensions.ldapAuthentication.wgLDAPUseSSL | Connect to LDAP server(s) over SSL (ldaps) | `false`
mediawiki.extensions.ldapAuthentication.wgLDAPUseLocal | Allow the use of the local database as well as the LDAP database | `false`
mediawiki.extensions.ldapAuthentication.wgLDAPAddLDAPUsers | Allow addition of wiki user to LDAP | `false`
mediawiki.extensions.ldapAuthentication.wgLDAPUpdateLDAP | Allow updating LDAP with local wiki user preferences | `false`
mediawiki.extensions.ldapAuthentication.wgLDAPMailPassword | Mail temporary passwords to users - this is useless if you're unable to write the password to your LDAP directory | `false`
mediawiki.extensions.ldapAuthentication.wgLDAPGroupUseFullDN | Whether the username in the group is a full DN (AD generally does this), or just the username (posix groups generally do this) | `false`
mediawiki.extensions.ldapAuthentication.wgLDAPEncryptionType | The type of encryption you would like to use when connecting to the LDAP server | `clear`
mediawiki.extensions.ldapAuthentication.wgLDAPDomainNames | The names of one or more domains you wish to use | `[]`
mediawiki.extensions.ldapAuthentication.wgLDAPServerNames | The fully qualified name of one or more servers per domain you wish to use | `{}`
mediawiki.extensions.ldapAuthentication.wgLDAPSearchStrings | The search string to be used for straight binds to the directory; USER-NAME will be replaced by the username of the user logging in. | `{}`
mediawiki.extensions.ldapAuthentication.wgLDAPGroupObjectclass | The objectclass of the groups we want to search for | `{}`
mediawiki.extensions.ldapAuthentication.wgLDAPGroupSearchNestedGroups | Whether or not the plugin should search in nested groups | `{}`
mediawiki.extensions.ldapAuthentication.wgLDAPGroupNameAttribute | The naming attribute of the group | `{}`
mediawiki.extensions.ldapAuthentication.wgLDAPBaseDNs | Base DNs. Group and User base DNs will be used if available; if they are not defined, the search will default to $wgLDAPBaseDNs | `{}`

#### Math

Extension Website: https://www.mediawiki.org/wiki/Extension:Math

Parameter | Description | Default
--------- | ----------- | -------
mediawiki.extensions.math.enabled | Enable/disable this extension | `false`
mediawiki.wgDefaultUserOptions | With the 'math' key in wgDefaultUserOptions, you can set the default math output mode. Your choices are 'mathml', 'png' and  'source' | `mathml`
mediawiki.extensions.math.wgMathFullRestbasURL | When using mathoid as a service (mathml), this specifies the RESTbase service URL | `nil`
mediawiki.extensions.math.wgMathoidCli | When using mathoid as a cli tool, this array type specifies the mathoid command argument vector | `[]`
mediawiki.extensions.math.wgMathValidModes | Defines the allowed modes on the server | `[png,source,mathml]`
mediawiki.extensions.math.wgMathDisableTexFilter | Disable the tex filter. If set to true any LaTeX expression is parsed this can be a potential security risk. If set to false only a subset of the TeX commands is allowed. "always" disables this feature | `never`

#### Replace Text

Extension Website: https://www.mediawiki.org/wiki/Extension:Replace\_Text

Parameter | Description | Default
--------- | ----------- | -------
mediawiki.extensions.replaceText.enabled | Enable/disable this extension | `false`
mediawiki.extensions.replaceText.wgReplaceTextUser | Set $wgReplaceTextUser to define a specific user to whom all edits will be credited | `undefined`

#### NativeSVGHandler

Extension Website: https://www.mediawiki.org/wiki/Extension:NativeSvgHandler

Parameter | Description | Default
--------- | ----------- | -------
mediawiki.extensions.nativeSVGHandler.enabled | Enable/disable this extension | `false`
mediawiki.extensions.nativeSVGHandler.wgNativeSvgHandlerEnableLinks | Set false to disable links over SVG images | `true`

#### Semantic MediaWiki

Extension Website: https://www.semantic-mediawiki.org

Parameter | Description | Default
--------- | ----------- | -------
mediawiki.extensions.semanticMediaWiki.enabled | Enable/disable this extension | `false`

#### SVGEdit

Extension Website: https://www.mediawiki.org/wiki/Extension:SVGEdit

Parameter | Description | Default
--------- | ----------- | -------
mediawiki.extensions.SVGEdit.enabled | Enable/disable this extension | `false`
mediawiki.extensions.SVGEdit.wgSVGEditEditor | This option allows using an externally hosted instance of the SVG-edit editor iframe (see https://www.mediawiki.org/wiki/Extension:SVGEdit for more details) | `nil`

#### UserMerge

Extension Website: https://www.mediawiki.org/wiki/Extension:UserMerge

Parameter | Description | Default
--------- | ----------- | -------
mediawiki.extensions.userMerge.enabled | Enable/disable this extension | `false`
mediawiki.wgGroupPermissions | Groups in the wgGroupPermissions table can have an option called "usermerge" that can be either true or false to allow or disallow usermerge functionality for people in those groups | `false`
mediawiki.extensions.userMerge.wgUserMergeProtectedGroups | This array defines groups whose members can't be merged | `[sysop]`

#### WikiEditor

Extension Website: https://www.mediawiki.org/wiki/Extension:WikiEditor

Parameter | Description | Default
--------- | ----------- | -------
mediawiki.extensions.wikiEditor.enabled | Enable/disable this extension | `false`
mediawiki.wgHiddenPrefs | Add the option "usebetatoolbar" to the wgHiddenPrefs array to make it impossible for users to disable this extension in their preferences | `nil`
mediawiki.wgDefaultUserOptions | Add a true value to the "usebetatoolbar" entry in wgDefaultUserOptions to make the WikiEditor toolbar default for all new users. Only available for versions 1.31+ | `false`

## MIGRATION

The MediaWiki Helm chart can migrate Wikis from other sources by connecting
to the host server and copying the relevant static content over to the new host.
This is done by temporarily opening access to the new MediaWiki instance to the
original host with netcat and local commands that grant access to local
resources. Care should be taken to _only_ run the below commands when a
migration is expected to take place, and immediately removing them afterward.
Otherwise, you'll be potentially leaving the original system wide open to
access from unauthorized parties.

### Making Static Content Available

We'll use netcat to make the output of tar available to our new MediaWiki
instance to pull in and store locally. For this step, you'll simply need to
find the location of your wiki's public upload directory. Typically this is
called images/ under your wiki root.

Once found, use netcat command will work with tar:

```bash
# In this example, our wiki lives at /var/www/wiki
$ tar -C /var/www/wiki/images -cvjf - ./ | nc -N -l 8001
```

When the command has finished running, it should automatically close and
terminate the existing socket, but it's a good idea to double check this when
the transfer finishes.

### Securing Netcats

The reason for using netcat to run transfers, (making your potentially
sensitive information available to the public) is that it removes the need for
the Kubernetes deployment to store login and database credentials locally. A
database may exist for much longer after the wiki has been migrated, and the
same applies for the server hosting the wiki content. This method makes the
server vulnerable for only a short period of time, but then doesn't persist
sensitive data in a separate location.

So if you're worried about making your listening netcat ports available to the
outside world, you can use the listening server's firewall settings to allow
only the new wiki host IP(s) to gain access.

You can get the list of allowed Kubernetes cluster IPs with kubectl, by listing
out the nodes and grabbing the "InternalIP" setting:

```bash
$ kubectl describe nodes | grep InternalIP
```

All of the IPs in that list should be allowed access to the ports that netcat
will open (typically 8000, and 8001, but can be set with the
migration.databasePort and migration.contentPort values, respectively).

As a simple example, for nodes with IPs 142.90.143.91, 142.90.143.92,
142.90.143.93, 142.90.143.94 and 142.90.143.95 you can use iptables like this:

```bash
$ for i in 142.90.143.91 142.90.143.92 142.90.143.93 142.90.143.94 142.90.143.95; do \
    iptables -A INPUT -p tcp --dport 8000 -s $i -j ACCEPT;
  done
$ iptables -A INPUT -p tcp --dport 8000 -j DROP
```

This will drop all connections from hosts that don't come from the source IPs
for your Kubernetes cluster.
