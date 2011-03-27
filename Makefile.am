ACLOCAL_AMFLAGS  = -I m4 ${ACLOCAL_FLAGS}

CP = cp

CLEANFILES =

SUBDIRS = po
EXTRA_DIST = autogen.bash NEWS README

bin_PROGRAMS = twident

base_twident_SOURCES = \
    src/time_utils.vala \
    src/create_dialog_generic.vala \
    src/identica_create_dialog.vala \
    src/icon_with_status_cell_renderer.vala \
    src/stream_state.vala \
    src/timer.vala \
    src/twitter_stream_home.vala \
    src/main.vala \
    src/twitter_stream_mentions.vala \
    src/account_state.vala \
    src/meta_row.vala \
    src/search_interface.vala \
    src/twitter_stream_public.vala \
    src/hig_table.vala \
    src/twitter_recursive_reply.vala \
    src/avatar.vala \
    src/streams_types.vala \
    src/status_delegate.vala \
    src/twitter_parser.vala \
    src/accounts.vala \
    src/stream_meta.vala \
    src/status_choose_bar.vala \
    src/reply_label.vala \
    src/event_box_tr.vala \
    src/twident_enums.vala \
    src/visual_style.vala \
    src/stream_abstract.vala \
    src/img_cache.vala \
    src/twitter_account.vala \
    src/status_box.vala \
    src/bg_box.vala \
    src/thumb.vala \
    src/identica_stream_group.vala \
    src/text_input.vala \
    src/feed_view.vala \
    src/search_dialog.vala \
    src/main_window.vala \
    src/status.vala \
    src/feed_model.vala \
    src/wrap_label.vala \
    src/twitter_favorites_stream.vala \
    src/utils.vala \
    src/twitter_create_dialog.vala \
    src/conversation_view.vala \
    src/twitter_stream_abstract.vala \
    src/tree_widget.vala \
    src/accounts_types.vala \
    src/view_area.vala \
    src/settings.vala \
    src/updates_cell_renderer.vala \
    src/account_abstract.vala \
    src/identica_account.vala \
    src/twitter_stream_search.vala \
    src/globals.vala

extra_twident_SOURCES = \
    vapi/time_parser.c \
    vapi/img_cache_saver.c

twident_SOURCES = \
    $(base_twident_SOURCES) \
    $(extra_twident_SOURCES)

twident_VALAFLAGS = \
    --thread \
    --debug \
    --vapidir=vapi \
    $(GTK_VALAFLAGS) \
    $(GIO_VALAFLAGS) \
    $(GEE_VALAFLAGS) \
    $(LIBNOTIFY_VALAFLAGS) \
    $(LIBSOUP_VALAFLAGS) \
    $(LIBXML_VALAFLAGS) \
    $(REST_VALAFLAGS) \
    $(RESTEXTRAS_VALAFLAGS) \
    --pkg=config \
    --pkg=posix

imgdir = ${datadir}/twident/icons

twident_CFLAGS = \
    $(GTK_CFLAGS) \
    $(GIO_CFLAGS) \
    $(GLIB_CFLAGS) \
    $(GEE_CFLAGS) \
    $(LIBNOTIFY_CFLAGS) \
    $(LIBSOUP_CFLAGS) \
    $(LIBXML_CFLAGS) \
    $(REST_CFLAGS) \
    $(RESTEXTRAS_CFLAGS) \
    --include config.h \
    -I vapi \
    -DLOCALEDIR=\"${localedir}\" \
    -DMENTIONS_PATH=\"${imgdir}/mentions.svg\" \
    -DGROUP_PATH=\"${imgdir}/group.svg\" \
    -DRT_PATH=\"${imgdir}/rt.png\" \
    -DCONVERSATION_PATH=\"${imgdir}/conversation.png\" \
    -DSERVICE_TWITTER_ICON=\"${imgdir}/service-twitter.png\" \
    -DSERVICE_IDENTICA_ICON=\"${imgdir}/service-identica.png\" \
    -DUPDATING_PATH=\"${imgdir}/updating.png\" \
    -DRETWEET_PATH=\"${imgdir}/retweet.svg\" \
    $(CFLAGS)

CLEANFILES += \
	${base_twident_SOURCES:.vala=.c}

twident_LDADD = \
    $(GTK_LIBS) \
    $(GIO_LIBS) \
    $(GLIB_LIBS) \
    $(GEE_LIBS) \
    $(LIBNOTIFY_LIBS) \
    $(LIBSOUP_LIBS) \
    $(LIBXML_LIBS) \
    $(REST_LIBS) \
    $(RESTEXTRAS_LIBS)

img_DATA = \
    img/delete_status.png \
    img/direct_fresh.svg \
    img/direct_reply.png \
    img/direct.svg \
    img/service-twitter.png \
    img/service-identica.png \
    img/mentions_fresh.svg \
    img/mentions.svg \
    img/group.svg \
    img/reply.png \
    img/timeline_fresh.svg \
    img/timeline.svg \
    img/public.svg \
    img/userpic.svg \
    img/updating.png \
    img/retweet.svg \
    img/rt.png \
    img/conversation.png

icondir = ${datadir}/icons/hicolor/scalable/apps
icon_DATA = \
    img/twident_fresh.svg \
    img/twident.svg

desktopdir = ${datadir}/applications
desktop_DATA = twident.desktop
