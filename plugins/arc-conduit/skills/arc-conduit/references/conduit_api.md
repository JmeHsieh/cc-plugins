# Phabricator Conduit API Reference

This file documents all available Conduit API methods.
Use `arc call-conduit -- <method>` to invoke them.

## Usage

```bash
# Basic usage (pipe JSON params via stdin):
echo '{"key": "value"}' | arc call-conduit -- method.name

# Empty params:
echo '{}' | arc call-conduit -- conduit.ping
```

## Important Notes

- Always use `--` before the method name (required for non-interactive mode)
- Parameters are passed as JSON via stdin
- Response is JSON with `response` and `error_code` fields
- Search methods support `constraints`, `order`, `limit`, `after` (cursor pagination)

---

## maniphest

### maniphest.createtask

Create a new Maniphest task.

**Parameters:**

- `title` (required string)
- `description` (optional string)
- `ownerPHID` (optional phid)
- `viewPolicy` (optional phid or policy string)
- `editPolicy` (optional phid or policy string)
- `ccPHIDs` (optional list<phid>)
- `priority` (optional int)
- `projectPHIDs` (optional list<phid>)
- `auxiliary` (optional dict)

### maniphest.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### maniphest.gettasktransactions

Retrieve Maniphest task transactions.

**Parameters:**

- `ids` (required list<int>)

### maniphest.info

Retrieve information about a Maniphest task, given its ID.

**Parameters:**

- `task_id` (required id)

### maniphest.priority.search

Returns information about the possible priorities for Maniphest tasks.

### maniphest.query

Execute complex searches for Maniphest tasks.

**Parameters:**

- `ids` (optional list<uint>)
- `phids` (optional list<phid>)
- `ownerPHIDs` (optional list<phid>)
- `authorPHIDs` (optional list<phid>)
- `projectPHIDs` (optional list<phid>)
- `ccPHIDs` (optional list<phid>)
- `fullText` (optional string)
- `status` (optional string-constant<"status-any", "status-open", "status-closed", "status-resolved", "status-wontfix", "status-invalid", "status-spite", "status-duplicate">)
- `order` (optional string-constant<"order-priority", "order-created", "order-modified">)
- `limit` (optional int)
- `offset` (optional int)

### maniphest.querystatuses

Retrieve information about possible Maniphest task status values.

### maniphest.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

**Example — search by IDs:**

```bash
echo '{"constraints": {"ids": [12345, 12346]}}'  \
  | arc call-conduit -- maniphest.search
```

**Example — search by assignee:**

```bash
echo '{"constraints": {"assigned": ["PHID-USER-xxx"]}, "limit": 10}'  \
  | arc call-conduit -- maniphest.search
```

**Response structure:**

```json
{
  "response": {
    "data": [
      {
        "id": 12345,
        "phid": "PHID-TASK-xxx",
        "fields": {
          "name": "Task title",
          "description": { "raw": "..." },
          "status": { "value": "open" },
          "priority": { "value": 50, "name": "High" },
          "authorPHID": "PHID-USER-xxx",
          "ownerPHID": "PHID-USER-xxx"
        }
      }
    ],
    "cursor": { "after": "123", "limit": 100 }
  }
}
```

### maniphest.status.search

Returns information about the possible statuses for Maniphest tasks.

### maniphest.update

Update an existing Maniphest task.

**Parameters:**

- `id` (optional int)
- `phid` (optional int)
- `title` (optional string)
- `description` (optional string)
- `ownerPHID` (optional phid)
- `viewPolicy` (optional phid or policy string)
- `editPolicy` (optional phid or policy string)
- `ccPHIDs` (optional list<phid>)
- `priority` (optional int)
- `projectPHIDs` (optional list<phid>)
- `auxiliary` (optional dict)
- `status` (optional string)
- `comments` (optional string)

---

## differential

### differential.changeset.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### differential.close

Close a Differential revision.

**Parameters:**

- `revisionID` (required int)

### differential.createcomment

Add a comment to a Differential revision.

**Parameters:**

- `revision_id` (required revisionid)
- `message` (optional string)
- `action` (optional string)
- `silent` (optional bool)
- `attach_inlines` (optional bool)

### differential.creatediff

Create a new Differential diff.

**Parameters:**

- `changes` (required list<dict>)
- `sourceMachine` (required string)
- `sourcePath` (required string)
- `branch` (required string)
- `bookmark` (optional string)
- `sourceControlSystem` (required string-constant<"svn", "git", "hg">)
- `sourceControlPath` (required string)
- `sourceControlBaseRevision` (required string)
- `creationMethod` (optional string)
- `lintStatus` (required string-constant<"none", "skip", "okay", "warn", "fail">)
- `unitStatus` (required string-constant<"none", "skip", "okay", "warn", "fail">)
- `repositoryPHID` (optional phid)
- `parentRevisionID` (deprecated)
- `authorPHID` (deprecated)
- `repositoryUUID` (deprecated)

### differential.createinline

Add an inline comment to a Differential revision.

**Parameters:**

- `revisionID` (optional revisionid)
- `diffID` (optional diffid)
- `filePath` (required string)
- `isNewFile` (required bool)
- `lineNumber` (required int)
- `lineLength` (optional int)
- `content` (required string)

### differential.createrawdiff

Create a new Differential diff from a raw diff source.

**Parameters:**

- `diff` (required string)
- `repositoryPHID` (optional string)
- `viewPolicy` (optional string)

### differential.createrevision

Create a new Differential revision.

**Parameters:**

- `user` (ignored)
- `diffid` (required diffid)
- `fields` (required dict)

### differential.diff.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### differential.getalldiffs

Load all diffs for given revisions from Differential.

**Parameters:**

- `revision_ids` (required list<int>)

### differential.getcommitmessage

Retrieve Differential commit messages or message templates.

**Parameters:**

- `revision_id` (optional revision_id)
- `fields` (optional dict<string, wild>)
- `edit` (optional string-constant<"edit", "create">)

### differential.getcommitpaths

Query which paths should be included when committing a Differential revision.

**Parameters:**

- `revision_id` (required int)

### differential.getdiff

Load the content of a diff from Differential by revision ID or diff ID.

**Parameters:**

- `revision_id` (optional id)
- `diff_id` (optional id)

### differential.getrawdiff

Retrieve a raw diff

**Parameters:**

- `diffID` (required diffID)

### differential.getrevision

Load the content of a revision from Differential.

**Parameters:**

- `revision_id` (required id)

### differential.getrevisioncomments

Retrieve Differential Revision Comments.

**Parameters:**

- `ids` (required list<int>)
- `inlines` (optional bool (deprecated))

### differential.parsecommitmessage

Parse commit messages for Differential fields.

**Parameters:**

- `corpus` (required string)
- `partial` (optional bool)

### differential.query

Query Differential revisions which match certain criteria.

**Parameters:**

- `authors` (optional list<phid>)
- `ccs` (optional list<phid>)
- `reviewers` (optional list<phid>)
- `paths` (unsupported)
- `commitHashes` (optional list<pair<string-constant<"gtcm", "gttr", "hgcm">, string>>)
- `status` (optional string-constant<"status-any", "status-open", "status-accepted", "status-needs-review", "status-needs-revision", "status-closed", "status-abandoned">)
- `order` (optional string-constant<"order-modified", "order-created">)
- `limit` (optional uint)
- `offset` (optional uint)
- `ids` (optional list<uint>)
- `phids` (optional list<phid>)
- `subscribers` (optional list<phid>)
- `responsibleUsers` (optional list<phid>)
- `branches` (optional list<string>)

### differential.querydiffs

Query differential diffs which match certain criteria.

**Parameters:**

- `ids` (optional list<uint>)
- `revisionIDs` (optional list<uint>)

### differential.revision.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### differential.revision.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

**Example — search by ID:**

```bash
echo '{"constraints": {"ids": [1234]}}'  \
  | arc call-conduit -- differential.revision.search
```

### differential.setdiffproperty

Attach properties to Differential diffs.

**Parameters:**

- `diff_id` (required diff_id)
- `name` (required string)
- `data` (required string)

### differential.updaterevision

Update a Differential revision.

**Parameters:**

- `id` (required revisionid)
- `diffid` (required diffid)
- `fields` (required dict)
- `message` (required string)

---

## diffusion

### diffusion.blame

Get blame information for a list of paths.

**Parameters:**

- `paths` (required list<string>)
- `commit` (required string)
- `timeout` (optional int)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.branchquery

Determine what branches exist for a repository.

**Parameters:**

- `closed` (optional bool)
- `limit` (optional int)
- `offset` (optional int)
- `contains` (optional string)
- `patterns` (optional list<string>)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.browsequery

File(s) information for a repository at an (optional) path and (optional) commit.

**Parameters:**

- `path` (optional string)
- `commit` (optional string)
- `needValidityOnly` (optional bool)
- `limit` (optional int)
- `offset` (optional int)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.commit.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### diffusion.commit.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### diffusion.commitparentsquery

Get the commit identifiers for a commit's parent or parents.

**Parameters:**

- `commit` (required string)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.diffquery

Get diff information from a repository for a specific path at an (optional) commit.

**Parameters:**

- `path` (required string)
- `commit` (optional string)
- `encoding` (optional string)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.existsquery

Determine if code exists in a version control system.

**Parameters:**

- `commit` (required string)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.filecontentquery

Retrieve file content from a repository.

**Parameters:**

- `path` (required string)
- `commit` (required string)
- `timeout` (optional int)
- `byteLimit` (optional int)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.findsymbols

Retrieve Diffusion symbol information.

**Parameters:**

- `name` (optional string)
- `namePrefix` (optional string)
- `context` (optional string)
- `language` (optional string)
- `type` (optional string)
- `repositoryPHID` (optional string)

### diffusion.getlintmessages

Get lint messages for existing code.

**Parameters:**

- `repositoryPHID` (required phid)
- `branch` (required string)
- `commit` (optional string)
- `files` (required list<string>)

### diffusion.getrecentcommitsbypath

Get commit identifiers for recent commits affecting a given path.

**Parameters:**

- `callsign` (required string)
- `path` (required string)
- `branch` (optional string)
- `limit` (optional int)

### diffusion.historyquery

Returns history information for a repository at a specific commit and path.

**Parameters:**

- `commit` (required string)
- `against` (optional string)
- `path` (required string)
- `offset` (optional int)
- `limit` (required int)
- `needDirectChanges` (optional bool)
- `needChildChanges` (optional bool)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.internal.ancestors

Internal method for filtering ref ancestors.

**Parameters:**

- `ref` (required string)
- `commits` (required list<string>)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.internal.gitrawdiffquery

Internal method for getting raw diff information.

**Parameters:**

- `commit` (required string)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.lastmodifiedquery

Get the commits at which paths were last modified.

**Parameters:**

- `paths` (required map<string, string>)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.looksoon

Advises this server to look for new commits in a repository as soon as possible. This advice is most useful if you have just pushed new commits to that repository.

**Parameters:**

- `callsigns` (optional list<string> (deprecated))
- `repositories` (optional list<string>)
- `urgency` (optional string)

### diffusion.mergedcommitsquery

Merged commit information for a specific commit in a repository.

**Parameters:**

- `commit` (required string)
- `limit` (optional int)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.querycommits

Retrieve information about commits.

**Parameters:**

- `ids` (optional list<int>)
- `phids` (optional list<phid>)
- `names` (optional list<string>)
- `repositoryPHID` (optional phid)
- `needMessages` (optional bool)
- `bypassCache` (optional bool)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### diffusion.querypaths

Filename search on a repository.

**Parameters:**

- `path` (required string)
- `commit` (required string)
- `pattern` (optional string)
- `limit` (optional int)
- `offset` (optional int)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.rawdiffquery

Get raw diff information from a repository for a specific commit at an (optional) path.

**Parameters:**

- `commit` (required string)
- `path` (optional string)
- `linesOfContext` (optional int)
- `againstCommit` (optional string)
- `timeout` (optional int)
- `byteLimit` (optional int)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.refsquery

Query a git repository for ref information at a specific commit.

**Parameters:**

- `commit` (required string)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.repository.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### diffusion.repository.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

**Example:**

```bash
echo '{"constraints": {"callsigns": ["RP"]}}'  \
  | arc call-conduit -- diffusion.repository.search
```

### diffusion.resolverefs

Resolve references into stable, canonical identifiers.

**Parameters:**

- `refs` (required list<string>)
- `types` (optional list<string>)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.searchquery

Search (grep) a repository at a specific path and commit.

**Parameters:**

- `path` (required string)
- `commit` (optional string)
- `grep` (required string)
- `limit` (optional int)
- `offset` (optional int)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.tagsquery

Retrieve information about tags in a repository.

**Parameters:**

- `names` (optional list<string>)
- `commit` (optional string)
- `needMessages` (optional bool)
- `offset` (optional int)
- `limit` (optional int)
- `callsign` (optional string (deprecated))
- `repository` (optional string)
- `branch` (optional string)

### diffusion.updatecoverage

Publish coverage information for a repository.

**Parameters:**

- `repositoryPHID` (required phid)
- `branch` (required string)
- `commit` (required string)
- `coverage` (required map<string, string>)
- `mode` (optional string-constant<"overwrite", "update">)

### diffusion.uri.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

---

## project

### project.column.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### project.create

Create a project.

**Parameters:**

- `name` (required string)
- `members` (optional list<phid>)
- `icon` (optional string)
- `color` (optional string)
- `tags` (optional list<string>)

### project.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### project.query

Execute searches for Projects.

**Parameters:**

- `ids` (optional list<int>)
- `names` (optional list<string>)
- `phids` (optional list<phid>)
- `slugs` (optional list<string>)
- `icons` (optional list<string>)
- `colors` (optional list<string>)
- `status` (optional string-constant<"status-any", "status-open", "status-closed", "status-active", "status-archived">)
- `members` (optional list<phid>)
- `limit` (optional int)
- `offset` (optional int)

### project.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

**Example — search by name:**

```bash
echo '{"constraints": {"name": "ProjectName"}}'  \
  | arc call-conduit -- project.search
```

---

## user

### user.disable

Permanently disable specified users (admin only).

**Parameters:**

- `phids` (required list<phid>)

### user.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### user.enable

Re-enable specified users (admin only).

**Parameters:**

- `phids` (required list<phid>)

### user.find

Lookup PHIDs by username. Obsoleted by "user.query".

**Parameters:**

- `aliases` (required list<string>)

### user.query

Query users.

**Parameters:**

- `usernames` (optional list<string>)
- `emails` (optional list<string>)
- `realnames` (optional list<string>)
- `phids` (optional list<phid>)
- `ids` (optional list<uint>)
- `offset` (optional int)
- `limit` (optional int (default = 100))

### user.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

**Example — search by username:**

```bash
echo '{"constraints": {"usernames": ["johndoe"]}}'  \
  | arc call-conduit -- user.search
```

### user.whoami

Retrieve information about the logged-in user.

**Example:**

```bash
echo '{}' | arc call-conduit -- user.whoami
```

---

## file

### file.allocate

Prepare to upload a file.

**Parameters:**

- `name` (string)
- `contentLength` (int)
- `contentHash` (optional string)
- `viewPolicy` (optional string)
- `deleteAfterEpoch` (optional int)

### file.download

Download a file from the server.

**Parameters:**

- `phid` (required phid)

### file.info

Get information about a file.

**Parameters:**

- `phid` (optional phid)
- `id` (optional id)

### file.querychunks

Get information about file chunks.

**Parameters:**

- `filePHID` (phid)

### file.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### file.upload

Upload a file to the server.

**Parameters:**

- `data_base64` (required nonempty base64-bytes)
- `name` (optional string)
- `viewPolicy` (optional valid policy string or <phid>)
- `canCDN` (optional bool)

### file.uploadchunk

Upload a chunk of file data to the server.

**Parameters:**

- `filePHID` (phid)
- `byteStart` (int)
- `data` (string)
- `dataEncoding` (string)

### file.uploadhash

Obsolete. Has no effect.

**Parameters:**

- `hash` (required nonempty string)
- `name` (required nonempty string)

---

## harbormaster

### harbormaster.artifact.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### harbormaster.build.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### harbormaster.build.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### harbormaster.buildable.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### harbormaster.buildable.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### harbormaster.buildplan.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### harbormaster.buildplan.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### harbormaster.createartifact

Use this method to attach artifacts to build targets while running builds. Artifacts can be used to carry data through a complex build workflow, provide extra information to users, or store build results.

When creating an artifact, you will choose an `artifactType` from this table. These types of artifacts are supported:
| Artifact Type | Name | Summary |
|-------------|--------------|--------------|
| `host` | **Drydock Host** | References a host lease from Drydock. |
| `working-copy` | **Drydock Working Copy** | References a working copy lease from Drydock. |
| `file` | **File** | Stores a reference to file data. |
| `uri` | **URI** | Stores a URI. |

Each artifact also needs an `artifactKey`, which names the artifact. Finally, you will provide some `artifactData` to fill in the content of the artifact. The data you provide depends on what type of artifact you are creating.
Drydock Host
--------------------------

References a host lease from Drydock.

Create an artifact of this type by passing `host` as the `artifactType`. When creating an artifact of this type, provide these parameters as a dictionary to `artifactData`:
| Key | Type | Description |
|-------------|--------------|--------------|
| `drydockLeasePHID` | //string// | Drydock working copy lease to create an artifact from. |
For example:
```lang=json
{
  "drydockLeasePHID": "PHID-DRYL-abcdefghijklmnopqrst"
}

```
Drydock Working Copy
--------------------------

References a working copy lease from Drydock.

Create an artifact of this type by passing `working-copy` as the `artifactType`. When creating an artifact of this type, provide these parameters as a dictionary to `artifactData`:
| Key | Type | Description |
|-------------|--------------|--------------|
| `drydockLeasePHID` | //string// | Drydock working copy lease to create an artifact from. |
For example:
```lang=json
{
  "drydockLeasePHID": "PHID-DRYL-abcdefghijklmnopqrst"
}

```
File
--------------------------

Stores a reference to file data.

Create an artifact of this type by passing `file` as the `artifactType`. When creating an artifact of this type, provide these parameters as a dictionary to `artifactData`:
| Key | Type | Description |
|-------------|--------------|--------------|
| `filePHID` | //string// | File to create an artifact from. |
For example:
```lang=json
{
  "filePHID": "PHID-FILE-abcdefghijklmnopqrst"
}

```
URI
--------------------------

Stores a URI.

With `ui.external`, you can use this artifact type to add links to build results in an external build system.

Create an artifact of this type by passing `uri` as the `artifactType`. When creating an artifact of this type, provide these parameters as a dictionary to `artifactData`:
| Key | Type | Description |
|-------------|--------------|--------------|
| `uri` | //string// | The URI to store. |
| `name` | //optional string// | Optional label for this URI. |
| `ui.external` | //optional bool// | If true, display this URI in the UI as an link to additional build details in an external build system. |
For example:
```lang=json
{
  "uri": "https://buildserver.mycompany.com/build/123/",
  "name": "View External Build Results",
  "ui.external": true
}

```

**Parameters:**

- `buildTargetPHID` (phid)
- `artifactKey` (string)
- `artifactType` (string)
- `artifactData` (map<string, wild>)

### harbormaster.log.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### harbormaster.queryautotargets

Load or create build autotargets.

**Parameters:**

- `objectPHID` (phid)
- `targetKeys` (list<string>)

### harbormaster.querybuildables

Query Harbormaster buildables.

**Parameters:**

- `ids` (optional list<id>)
- `phids` (optional list<phid>)
- `buildablePHIDs` (optional list<phid>)
- `containerPHIDs` (optional list<phid>)
- `manualBuildables` (optional bool)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### harbormaster.querybuilds

Query Harbormaster builds.

**Parameters:**

- `ids` (optional list<id>)
- `phids` (optional list<phid>)
- `buildStatuses` (optional list<string>)
- `buildablePHIDs` (optional list<phid>)
- `buildPlanPHIDs` (optional list<phid>)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### harbormaster.sendmessage

Pause, abort, restart, and report results for builds.

**Parameters:**

- `receiver` (required string|phid)
- `type` (required string-constant<"abort", "fail", "pass", "pause", "restart", "resume", "work">)
- `unit` (optional list<wild>)
- `lint` (optional list<wild>)
- `buildTargetPHID` (deprecated optional phid)

### harbormaster.step.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### harbormaster.step.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### harbormaster.target.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

---

## paste

### paste.create

Create a new paste.

**Parameters:**

- `content` (required string)
- `title` (optional string)
- `language` (optional string)

### paste.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### paste.info

Retrieve an array of information about a paste.

**Parameters:**

- `paste_id` (required id)

### paste.query

Query Pastes.

**Parameters:**

- `ids` (optional list<int>)
- `phids` (optional list<phid>)
- `authorPHIDs` (optional list<phid>)
- `after` (optional int)
- `limit` (optional int, default = 100)

### paste.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

---

## phid

### phid.info

Retrieve information about an arbitrary PHID.

**Parameters:**

- `phid` (required phid)

### phid.lookup

Look up objects by name.

**Parameters:**

- `names` (required list<string>)

### phid.query

Retrieve information about arbitrary PHIDs.

**Parameters:**

- `phids` (required list<phid>)

---

## conduit

### conduit.connect

Connect a session-based client.

**Parameters:**

- `client` (required string)
- `clientVersion` (required int)
- `clientDescription` (optional string)
- `user` (optional string)
- `authToken` (optional int)
- `authSignature` (optional string)
- `host` (deprecated)

### conduit.getcapabilities

List capabilities, wire formats, and authentication protocols available on this server.

### conduit.getcertificate

Retrieve certificate information for a user.

**Parameters:**

- `token` (required string)
- `host` (required string)

### conduit.ping

Basic ping for monitoring or a health-check.

### conduit.query

Returns the parameters of the Conduit methods.

---

## audit

### audit.query

Query audit requests.

**Parameters:**

- `auditorPHIDs` (optional list<phid>)
- `commitPHIDs` (optional list<phid>)
- `status` (optional string-constant<"audit-status-any", "audit-status-open", "audit-status-concern", "audit-status-accepted", "audit-status-partial"> (default = "audit-status-any"))
- `offset` (optional int)
- `limit` (optional int (default = 100))

---

## auth

### auth.logout

Terminate all web login sessions. If called via OAuth, also terminate the current OAuth token.

WARNING: This method does what it claims on the label. If you call this method via the test console in the web UI, it will log you out!

### auth.querypublickeys

Query public keys.

**Parameters:**

- `ids` (optional list<id>)
- `phids` (optional list<phid>)
- `objectPHIDs` (optional list<phid>)
- `keys` (optional list<string>)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

---

## badge

### badge.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### badge.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

---

## countdown

### countdown.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### countdown.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

---

## dashboard

### dashboard.panel.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

---

## drydock

### drydock.authorization.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### drydock.blueprint.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### drydock.blueprint.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### drydock.lease.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

### drydock.resource.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

---

## edge

### edge.search

Read edge relationships between objects.

**Parameters:**

- `sourcePHIDs` (list<phid>)
- `types` (list<const>)
- `destinationPHIDs` (optional list<phid>)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

---

## feed

### feed.query

Query the feed for stories

**Parameters:**

- `filterPHIDs` (optional list <phid>)
- `limit` (optional int (default 100))
- `after` (optional int)
- `before` (optional int)
- `view` (optional string (data, html, html-summary, text))

---

## flag

### flag.delete

Clear a flag.

**Parameters:**

- `id` (optional id)
- `objectPHID` (optional phid)

### flag.edit

Create or modify a flag.

**Parameters:**

- `objectPHID` (required phid)
- `color` (optional int)
- `note` (optional string)

### flag.query

Query flag markers.

**Parameters:**

- `ownerPHIDs` (optional list<phid>)
- `types` (optional list<type>)
- `objectPHIDs` (optional list<phid>)
- `offset` (optional int)
- `limit` (optional int (default = 100))

---

## internal

### internal.commit.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

---

## macro

### macro.creatememe

Generate a meme.

**Parameters:**

- `macroName` (string)
- `upperText` (optional string)
- `lowerText` (optional string)

### macro.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### macro.query

Retrieve image macro information.

**Parameters:**

- `authorPHIDs` (optional list<phid>)
- `phids` (optional list<phid>)
- `ids` (optional list<id>)
- `names` (optional list<string>)
- `nameLike` (optional string)

---

## owners

### owners.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### owners.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

---

## passphrase

### passphrase.query

Query credentials.

**Parameters:**

- `ids` (optional list<int>)
- `phids` (optional list<phid>)
- `needSecrets` (optional bool)
- `needPublicKeys` (optional bool)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

---

## portal

### portal.edit

This is a standard **ApplicationEditor** method which allows you to create and modify objects by applying transactions. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Edit%20Endpoints&type=article&jump=1 | Conduit API: Using Edit Endpoints ]]**.

**Parameters:**

- `transactions` (list<map<string, wild>>)
- `objectIdentifier` (optional id|phid|string)

### portal.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

---

## remarkup

### remarkup.process

Process text through remarkup.

**Parameters:**

- `context` (required string-constant<"phriction", "maniphest", "differential", "phame", "feed", "diffusion">)
- `contents` (required list<string>)

---

## repository

### repository.query

Query repositories.

**Parameters:**

- `ids` (optional list<int>)
- `phids` (optional list<phid>)
- `callsigns` (optional list<string>)
- `vcsTypes` (optional list<string>)
- `remoteURIs` (optional list<string>)
- `uuids` (optional list<string>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

---

## slowvote

### slowvote.info

Retrieve an array of information about a poll.

**Parameters:**

- `poll_id` (required id)

### slowvote.poll.search

This is a standard **ApplicationSearch** method which will let you list, query, or search for objects. For documentation on these endpoints, see **[[ https://we.phorge.it/diviner/find/?name=Conduit%20API%3A%20Using%20Search%20Endpoints&type=article&jump=1 | Conduit API: Using Search Endpoints ]]**.

**Parameters:**

- `queryKey` (optional string)
- `constraints` (optional map<string, wild>)
- `attachments` (optional map<string, bool>)
- `order` (optional order)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))

---

## token

### token.give

Give or change a token.

**Parameters:**

- `tokenPHID` (phid|null)
- `objectPHID` (phid)

### token.given

Query tokens given to objects.

**Parameters:**

- `authorPHIDs` (list<phid>)
- `objectPHIDs` (list<phid>)
- `tokenPHIDs` (list<phid>)

### token.query

Query tokens.

---

## transaction

### transaction.search

Read transactions and comments for a particular object or an entire object type.

**Parameters:**

- `objectIdentifier` (optional phid|string)
- `objectType` (optional string)
- `constraints` (optional map<string, wild>)
- `before` (optional string)
- `after` (optional string)
- `limit` (optional int (default = 100))
