# Makefile for vocabulary_design_team_2013_2017 conversion using reposurgeon
#
# Steps to using this:
# 1. Make sure reposurgeon and repotool are on your $PATH.
# 2. (Skip this step if you're starting from a stream file.) For svn, set
#    REMOTE_URL to point at the remote repository you want to convert;
#    you can use either an svn: URL or an rsync: URL for this.
#    If the repository is already in a DVCS such as hg or git,
#    set REMOTE_URL to either the normal cloning URL (starting with hg://,
#    git://, etc.) or to the path of a local clone.
# 3. For cvs, set CVS_HOST to the repo hostname and CVS_MODULE to the module,
#    then uncomment the line that builds REMOTE_URL
#    Note: for CVS hosts other than Sourceforge or Savannah you will need to
#    include the path to the CVS modules directory after the hostname.
# 4. Set any required read options, such as --user-ignores or --nobranch,
#    by setting READ_OPTIONS.
# 5. Optionally, replace the default value of DUMPFILTER with a
#    command or pipeline that actually filters the dump rather than
#    just copying it through.  The most usual reason to do this is
#    that your Subversion repository is multiproject and you want to
#    strip out one subtree for conversion with repocutter sift and pop
#    commands.  Note that if you ever did copies across project
#    subtrees this simple stripout will not work - you are in deep
#    trouble and should find an expert to advise you
# 6. Run 'make stubmap' to create a stub author map.
# 7. Run 'make' to build a converted repository.
#
# For a production-quality conversion you will need to edit the map
# file and the lift script.  During the process you can set EXTRAS to
# name extra metadata such as a comments message-box.
#
# Afterwards, you can use the *compare productions to check your work.
#

EXTRAS =
REMOTE_URL = https://svn.ietf.org/svn/tools/xml2rfc
#REMOTE_URL = https://vocabulary_design_team_2013_2017.googlecode.com/svn/
CVS_HOST = vocabulary_design_team_2013_2017.cvs.sourceforge.net
#CVS_HOST = cvs.savannah.gnu.org
CVS_MODULE = vocabulary_design_team_2013_2017
#REMOTE_URL = cvs://$(CVS_HOST)/vocabulary_design_team_2013_2017\#$(CVS_MODULE)
READ_OPTIONS = --branchify=vocabulary
DUMPFILTER = cat
VERBOSITY = "set progress"
REPOSURGEON = reposurgeon
LOGFILE = conversion.log

# Set and uncomment these if remote access tio Subversion needs credentials.
#export RUSERNAME=
#export RPASSWORD=

# Configuration ends here

.PHONY: local-clobber remote-clobber gitk gc compare clean dist stubmap

default: vocabulary_design_team_2013_2017-git

# Build the repository from the stream dump
vocabulary_design_team_2013_2017-git: vocabulary_design_team_2013_2017.svn vocabulary_design_team_2013_2017.opts vocabulary_design_team_2013_2017.lift vocabulary_design_team_2013_2017.map $(EXTRAS)
	$(REPOSURGEON) $(VERBOSITY) 'logfile $(LOGFILE)' 'script vocabulary_design_team_2013_2017.opts' "read $(READ_OPTIONS) <vocabulary_design_team_2013_2017.svn" 'authors read <vocabulary_design_team_2013_2017.map' 'sourcetype svn' 'prefer git' 'script vocabulary_design_team_2013_2017.lift' 'legacy write >vocabulary_design_team_2013_2017.fo' 'rebuild vocabulary_design_team_2013_2017-git'

# Build a stream dump from the local mirror
vocabulary_design_team_2013_2017.svn: vocabulary_design_team_2013_2017-mirror
	(cd vocabulary_design_team_2013_2017-mirror/ >/dev/null; repotool export) | $(DUMPFILTER) >vocabulary_design_team_2013_2017.svn

# Build a local mirror of the remote repository
vocabulary_design_team_2013_2017-mirror:
	repotool mirror $(REMOTE_URL) vocabulary_design_team_2013_2017-mirror

# Make a local checkout of the source mirror for inspection
%-checkout: %-mirror
	cd %-mirror >/dev/null; repotool checkout $(PWD)/%-checkout

# Force rebuild of stream from the local mirror on the next make
local-clobber: clean
	rm -fr vocabulary_design_team_2013_2017.fi vocabulary_design_team_2013_2017-git

# Force full rebuild from the remote repo on the next make.
remote-clobber: local-clobber
	rm -fr vocabulary_design_team_2013_2017.svn *-mirror *-checkout

# Get the (empty) state of the author mapping from the first-stage stream
stubmap: vocabulary_design_team_2013_2017.svn
	$(REPOSURGEON) $(VERBOSITY) "read $(READ_OPTIONS) <vocabulary_design_team_2013_2017.svn" 'authors write >vocabulary_design_team_2013_2017.map'

# Compare the histories of the unconverted and converted repositories at head
# and all tags.
headcompare: vocabulary_design_team_2013_2017-mirror vocabulary_design_team_2013_2017-git
	repotool compare vocabulary_design_team_2013_2017-mirror vocabulary_design_team_2013_2017-git
tagscompare: vocabulary_design_team_2013_2017-mirror vocabulary_design_team_2013_2017-git
	repotool compare-tags vocabulary_design_team_2013_2017-mirror vocabulary_design_team_2013_2017-git
branchescompare: vocabulary_design_team_2013_2017-mirror vocabulary_design_team_2013_2017-git
	repotool compare-branches vocabulary_design_team_2013_2017-mirror vocabulary_design_team_2013_2017-git
allcompare: vocabulary_design_team_2013_2017-mirror vocabulary_design_team_2013_2017-git
	repotool compare-all vocabulary_design_team_2013_2017-mirror vocabulary_design_team_2013_2017-git

# General cleanup and utility
clean:
	rm -fr *~ .rs* vocabulary_design_team_2013_2017-conversion.tar.gz *.svn *.fi *.fo

# Bundle up the conversion metadata for shipping
SOURCES = Makefile vocabulary_design_team_2013_2017.opts vocabulary_design_team_2013_2017.lift vocabulary_design_team_2013_2017.map $(EXTRAS)
vocabulary_design_team_2013_2017-conversion.tar.gz: $(SOURCES)
	tar --dereference --transform 's:^:vocabulary_design_team_2013_2017-conversion/:' -czvf vocabulary_design_team_2013_2017-conversion.tar.gz $(SOURCES)

dist: vocabulary_design_team_2013_2017-conversion.tar.gz

#
# The following productions are git-specific
#

# Browse the generated git repository
gitk: vocabulary_design_team_2013_2017-git
	cd vocabulary_design_team_2013_2017-git; gitk --all

# Run a garbage-collect on the generated git repository.  Import doesn't.
# This repack call is the active part of gc --aggressive.  This call is
# tuned for very large repositories.
gc: vocabulary_design_team_2013_2017-git
	cd vocabulary_design_team_2013_2017-git; time git -c pack.threads=1 repack -AdF --window=1250 --depth=250
