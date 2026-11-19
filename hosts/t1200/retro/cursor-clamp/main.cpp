// t1200 cursor-clamp: keep the pointer out of the bezel-hidden strips.
//
// Hyprland clamps every pointer position through CPointerManager::closestValid
// (motion, warps, absolute moves). We wrap it and additionally clamp x into
// each monitor's box minus its *reserved* left/right area, which bezel.nix sets
// to the bezel width. Top/bottom are left alone so the auto-hiding bar can
// still be revealed at the top edge.
#define WLR_USE_UNSTABLE

#include <algorithm>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/state/MonitorState.hpp>
#include <hyprland/src/output/Monitor.hpp>

inline HANDLE         PHANDLE = nullptr;
inline CFunctionHook* g_pHook = nullptr;

typedef Vector2D (*origClosestValid)(void*, const Vector2D&);

static Vector2D hkClosestValid(void* thisptr, const Vector2D& pos) {
    Vector2D p = (*(origClosestValid)g_pHook->m_original)(thisptr, pos);

    for (const auto& mon : State::monitorState()->monitors()) {
        if (!mon)
            continue;
        const CBox full = mon->logicalBox();
        if (!full.containsPoint(p))
            continue;

        const CBox   usable = mon->logicalBoxMinusReserved();
        const double minX   = usable.x;
        const double maxX   = usable.x + usable.w - 1.0;
        if (maxX > minX)
            p.x = std::clamp(p.x, minX, maxX);
        break;
    }
    return p;
}

APICALL EXPORT std::string PLUGIN_API_VERSION() {
    return HYPRLAND_API_VERSION;
}

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    PHANDLE = handle;

    // both return const char*: compare contents, not pointers
    if (std::string{__hyprland_api_get_hash()} != std::string{__hyprland_api_get_client_hash()}) {
        HyprlandAPI::addNotification(PHANDLE, "[cursor-clamp] version mismatch, not loaded", CHyprColor{1.0, 0.2, 0.2, 1.0}, 5000);
        throw std::runtime_error("[cursor-clamp] version mismatch");
    }

    for (const auto& fn : HyprlandAPI::findFunctionsByName(PHANDLE, "closestValid")) {
        if (!fn.demangled.contains("CPointerManager::closestValid"))
            continue;
        g_pHook = HyprlandAPI::createFunctionHook(PHANDLE, fn.address, (void*)::hkClosestValid);
        break;
    }

    if (!g_pHook || !g_pHook->hook()) {
        HyprlandAPI::addNotification(PHANDLE, "[cursor-clamp] failed to hook CPointerManager::closestValid", CHyprColor{1.0, 0.2, 0.2, 1.0}, 5000);
        throw std::runtime_error("[cursor-clamp] hook failed");
    }

    return {"cursor-clamp", "Keep the cursor inside each monitor's reserved left/right area", "t1200", "1.0"};
}

APICALL EXPORT void PLUGIN_EXIT() {
    // hooks registered through the API are removed by Hyprland on unload
}
