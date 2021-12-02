# Makefile for datatracker conversion using reposurgeon
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
REMOTE_URL = https://svn.ietf.org/svn/tools/datatracker
#REMOTE_URL = https://datatracker.googlecode.com/svn/
CVS_HOST = datatracker.cvs.sourceforge.net
#CVS_HOST = cvs.savannah.gnu.org
CVS_MODULE = datatracker
#REMOTE_URL = cvs://$(CVS_HOST)/datatracker\#$(CVS_MODULE)
READ_OPTIONS = --branchify=trunk:attic/*:branch/*:branch/*/*:personal/*:personal/*/*:sprint/*:sprint/*/*:tags/*:tags/dev/*:*
DUMPFILTER = cat
VERBOSITY = "set progress"
REPOSURGEON = reposurgeon
LOGFILE = conversion.log

# Set and uncomment these if remote access tio Subversion needs credentials.
#export RUSERNAME=
#export RPASSWORD=

# Configuration ends here

.PHONY: local-clobber remote-clobber gitk gc compare clean dist stubmap

default: datatracker-git

# Build the repository from the stream dump
datatracker-git: datatracker.svn datatracker.opts datatracker.lift datatracker.map $(EXTRAS)
	$(REPOSURGEON) $(VERBOSITY) 'logfile $(LOGFILE)' 'script datatracker.opts' "read $(READ_OPTIONS) <datatracker.svn" 'authors read <datatracker.map' 'sourcetype svn' 'prefer git' 'script datatracker.lift' 'legacy write >datatracker.fo' 'rebuild datatracker-git'

# Build a stream dump from the local mirror
datatracker.svn: datatracker-mirror
	(cd datatracker-mirror/ >/dev/null; repotool export) | $(DUMPFILTER) >datatracker.svn

# Build a local mirror of the remote repository
datatracker-mirror:
	repotool mirror $(REMOTE_URL) datatracker-mirror

# Make a local checkout of the source mirror for inspection
%-checkout: %-mirror
	cd %-mirror >/dev/null; repotool checkout $(PWD)/%-checkout

# Force rebuild of stream from the local mirror on the next make
local-clobber: clean
	rm -fr datatracker.fi datatracker-git

# Force full rebuild from the remote repo on the next make.
remote-clobber: local-clobber
	rm -fr datatracker.svn *-mirror *-checkout

# Get the (empty) state of the author mapping from the first-stage stream
stubmap: datatracker.svn
	$(REPOSURGEON) $(VERBOSITY) "read $(READ_OPTIONS) <datatracker.svn" 'authors write >datatracker.map'

# Compare the histories of the unconverted and converted repositories at head
# and all tags.
headcompare: datatracker-mirror datatracker-git
	repotool compare datatracker-mirror datatracker-git
tagscompare: datatracker-mirror datatracker-git
	repotool compare-tags datatracker-mirror datatracker-git
branchescompare: datatracker-mirror datatracker-git
	repotool compare-branches datatracker-mirror datatracker-git
allcompare: datatracker-mirror datatracker-git
	repotool compare-all datatracker-mirror datatracker-git

# General cleanup and utility
clean:
	rm -fr *~ .rs* datatracker-conversion.tar.gz *.svn *.fi *.fo

# Bundle up the conversion metadata for shipping
SOURCES = Makefile datatracker.opts datatracker.lift datatracker.map $(EXTRAS)
datatracker-conversion.tar.gz: $(SOURCES)
	tar --dereference --transform 's:^:datatracker-conversion/:' -czvf datatracker-conversion.tar.gz $(SOURCES)

dist: datatracker-conversion.tar.gz

#
# The following productions are git-specific
#

# Browse the generated git repository
gitk: datatracker-git
	cd datatracker-git; gitk --all

# Run a garbage-collect on the generated git repository.  Import doesn't.
# This repack call is the active part of gc --aggressive.  This call is
# tuned for very large repositories.
gc: datatracker-git
	cd datatracker-git; time git -c pack.threads=1 repack -AdF --window=1250 --depth=250
