#include <nsIInterfaceRequestorUtils.h>
#include <nsCOMPtr.h>
#include <nsIContentViewer.h>
#include <nsIDOMWindow.h>
#include <nsIDOMViewCSS.h>
#include <nsIWebBrowser.h>
#include <nsIDocShell.h>
#include <nsIMarkupDocumentViewer.h>
#include <nsEmbedString.h>
#include <nsIDOMCSSStyleDeclaration.h>

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

static SV *wrap_unichar_string(const PRUnichar *uni_str) {
	nsEmbedString utf8;
	nsEmbedCString u8c;
	const char * u8str;

	utf8 = uni_str;
	NS_UTF16ToCString(utf8, NS_CSTRING_ENCODING_UTF8, u8c);

	u8str = u8c.get();
	return newSVpv(u8str, 0);
}

static nsIMarkupDocumentViewer *get_markup_viewer(SV *bro_sv) {
	nsCOMPtr<nsIContentViewer> cviewer;
	nsIWebBrowser *bro = INT2PTR(nsIWebBrowser *, SvIV(SvRV(bro_sv)));
	nsCOMPtr<nsIDocShell> dsh = do_GetInterface(bro);
	nsCOMPtr<nsIMarkupDocumentViewer> mdv;
	if (!dsh)
		return NULL;

	dsh->GetContentViewer(getter_AddRefs(cviewer));
	if (!cviewer)
		return NULL;

	mdv = do_QueryInterface(cviewer);
	if (!mdv)
		return NULL;

	return mdv;
}

MODULE = Mozilla::DOM::ComputedStyle		PACKAGE = Mozilla::DOM::ComputedStyle		

nsEmbedString
Get_Computed_Style_Property(win, elem, pname)
	SV *win;
	SV *elem;
	nsEmbedCString pname;
	INIT:
		nsCOMPtr<nsIDOMCSSStyleDeclaration> comp_style;
		nsIDOMWindow *window;
		nsIDOMViewCSS *w = 0;
		nsresult rv;
		nsEmbedString nspn, ret;
		SV *res = 0;
	CODE:
		window = INT2PTR(nsIDOMWindow *, SvIV(SvRV(win)));
		window->QueryInterface(NS_GET_IID(nsIDOMViewCSS), (void **) &w);
		if (!w)
			goto done;

		w->GetComputedStyle(INT2PTR(nsIDOMElement *, SvIV(SvRV(elem)))
				 , EmptyString()
				 , getter_AddRefs(comp_style));
		w->Release();
		if (!comp_style)
			goto done;

		NS_CStringToUTF16(pname, NS_CSTRING_ENCODING_UTF8, nspn);
		rv = comp_style->GetPropertyValue(nspn, ret);
done:
		if (!ret.get())
			XSRETURN_UNDEF;

		RETVAL = ret;
	OUTPUT:
		RETVAL

float Get_Full_Zoom(SV *bro_sv)
	INIT:
		float ret;
	        nsCOMPtr<nsIMarkupDocumentViewer> mdv;
	CODE:
		mdv = get_markup_viewer(bro_sv);
		if (!mdv)
			XSRETURN_UNDEF;

		mdv->GetFullZoom(&ret);
		RETVAL = ret;
	OUTPUT:
		RETVAL

void Set_Full_Zoom(SV *bro_sv, float zoom)
	INIT:
	        nsCOMPtr<nsIMarkupDocumentViewer> mdv;
	CODE:
		mdv = get_markup_viewer(bro_sv);
		if (mdv)
			mdv->SetFullZoom(zoom);

