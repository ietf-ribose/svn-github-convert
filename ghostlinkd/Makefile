# Makefile for ghostlinkd conversion using reposurgeon
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
REMOTE_URL = https://svn.ietf.org/svn/tools/ghostlinkd
#REMOTE_URL = https://ghostlinkd.googlecode.com/svn/
CVS_HOST = ghostlinkd.cvs.sourceforge.net
#CVS_HOST = cvs.savannah.gnu.org
CVS_MODULE = ghostlinkd
#REMOTE_URL = cvs://$(CVS_HOST)/ghostlinkd\#$(CVS_MODULE)
READ_OPTIONS =
DUMPFILTER = cat
VERBOSITY = "set progress"
REPOSURGEON = reposurgeon
LOGFILE = conversion.log

# Set and uncomment these if remote access tio Subversion needs credentials.
#export RUSERNAME=
#export RPASSWORD=

# Configuration ends here

.PHONY: local-clobber remote-clobber gitk gc compare clean dist stubmap

default: ghostlinkd-git

# Build the repository from the stream dump
ghostlinkd-git: ghostlinkd.svn ghostlinkd.opts ghostlinkd.lift ghostlinkd.map $(EXTRAS)
	$(REPOSURGEON) $(VERBOSITY) 'logfile $(LOGFILE)' 'script ghostlinkd.opts' "read $(READ_OPTIONS) <ghostlinkd.svn" 'authors read <ghostlinkd.map' 'sourcetype svn' 'prefer git' 'script ghostlinkd.lift' 'legacy write >ghostlinkd.fo' 'rebuild ghostlinkd-git'

# Build a stream dump from the local mirror
ghostlinkd.svn: ghostlinkd-mirror
	(cd ghostlinkd-mirror/ >/dev/null; repotool export) | $(DUMPFILTER) >ghostlinkd.svn

# Build a local mirror of the remote repository
ghostlinkd-mirror:
	repotool mirror $(REMOTE_URL) ghostlinkd-mirror

# Make a local checkout of the source mirror for inspection
%-checkout: %-mirror
	cd %-mirror >/dev/null; repotool checkout $(PWD)/%-checkout

# Force rebuild of stream from the local mirror on the next make
local-clobber: clean
	rm -fr ghostlinkd.fi ghostlinkd-git

# Force full rebuild from the remote repo on the next make.
remote-clobber: local-clobber
	rm -fr ghostlinkd.svn *-mirror *-checkout

# Get the (empty) state of the author mapping from the first-stage stream
stubmap: ghostlinkd.svn
	$(REPOSURGEON) $(VERBOSITY) "read $(READ_OPTIONS) <ghostlinkd.svn" 'authors write >ghostlinkd.map'

# Compare the histories of the unconverted and converted repositories at head
# and all tags.
headcompare: ghostlinkd-mirror ghostlinkd-git
	repotool compare ghostlinkd-mirror ghostlinkd-git
tagscompare: ghostlinkd-mirror ghostlinkd-git
	repotool compare-tags ghostlinkd-mirror ghostlinkd-git
branchescompare: ghostlinkd-mirror ghostlinkd-git
	repotool compare-branches ghostlinkd-mirror ghostlinkd-git
allcompare: ghostlinkd-mirror ghostlinkd-git
	repotool compare-all ghostlinkd-mirror ghostlinkd-git

# General cleanup and utility
clean:
	rm -fr *~ .rs* ghostlinkd-conversion.tar.gz *.svn *.fi *.fo

# Bundle up the conversion metadata for shipping
SOURCES = Makefile ghostlinkd.opts ghostlinkd.lift ghostlinkd.map $(EXTRAS)
ghostlinkd-conversion.tar.gz: $(SOURCES)
	tar --dereference --transform 's:^:ghostlinkd-conversion/:' -czvf ghostlinkd-conversion.tar.gz $(SOURCES)

dist: ghostlinkd-conversion.tar.gz

#
# The following productions are git-specific
#

# Browse the generated git repository
gitk: ghostlinkd-git
	cd ghostlinkd-git; gitk --all

# Run a garbage-collect on the generated git repository.  Import doesn't.
# This repack call is the active part of gc --aggressive.  This call is
# tuned for very large repositories.
gc: ghostlinkd-git
	cd ghostlinkd-git; time git -c pack.threads=1 repack -AdF --window=1250 --depth=250
