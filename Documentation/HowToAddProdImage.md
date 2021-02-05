## Production Images

The basic point of Yocto is the being able to build a very flexible Linux image.  That is what we are trying to do with this project.  Our systems are robust and very flexible, they have to be in order to meet all the challenges presented to the group.  That is why this structure is inteded to help **speed** up the process of building as lightweight as possible image for a particular solution.

The file structure is as follows:
<pre>
sources/
    meta-ornl/
        recipes-core/
            images/
                ornl-dev-image.bb
                ornl-tstar-image.bb
            packagegroups/
                ornlpackagegroup-prod.bb
</pre>

**Create Image Recipe**

From the above structure we have two image builds; dev-image and a tstar-image.  To create a new production image copy the tstar image and rename it to the project you want to *fine tune* the image for.  The Packagegroup listed in the structure can be imaged as the base of all our production builds, and in a round about way, we can think of our production images inheriting from that image.  The tstar image already takes that in to consideration, so just copy, paste, and rename.

**What To Add** 

So far we have been appending to the global variable IMAGE_FEATURES and CORE_IMAGE_EXTRA_INSTALL.  The links below take you to a list of available packages that can be added.  To list those is a bit out of the purview of this document.

[IMAGE_FEATURES](https://www.yoctoproject.org/docs/current/mega-manual/mega-manual.html#ref-features-image)

[CORE_IMAGE_EXTRA_INSTALL](https://www.yoctoproject.org/docs/current/mega-manual/mega-manual.html#var-EXTRA_IMAGE_FEATURES)

**How to Build**

After setting up the build environment (see README.md), all you will need to run is the following command.
<pre>
bitbake < name-of-your-image >
</pre>

After how ever long it takes, you will then have a new *production* ready image.

**SWUpdate Files**

If SWUpdate files exist for the new image then they will need to be tracked as well.  Those typically reside in the recipes-support/ directory under swupdate.  See the Update Guide file for more information. The most important SWUpdate files to add are the artifact recipes, i.e. var-dev-image-swu.bb.  If this is a new project, you might consider adding a recipe to build a new update artifact or maybe just adding on to one that already exists.
