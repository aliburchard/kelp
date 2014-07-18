project = require "zooniverse-readymade/current-project"
classifyPage = project.classifyPages[0]
translate = require "t7e"

class ClassifyMenu
  GROUPS =
    'all-locations': true
    'california': "53ac8475edf877f0bc000002"
    'tasmania': "536d226d3ae740fd20000003"

  html = """
    <div id='classify-menu'>
      <div class='menu-tabs'>
        <div class='tab' id='tutorial-tab'><img src='./icons/tut.svg'>#{translate 'classifyMenu.tab.tutorial'}</div>
        <div class='tab'><img src='./icons/guide.svg'>#{translate 'classifyMenu.tab.fieldGuide'}</div>
        <div class='tab'><img src='./icons/location.svg'>#{translate 'classifyMenu.tab.location'}</div>
        <div class='tab' id='favorites-tab'><img src='./icons/favorite.svg'>#{translate 'classifyMenu.tab.favorites'}</div>
      </div>

      <div class='menu-content'>
        <div class='menu-section'>
          <h1>Tutorial Menu section</h1>
        </div>
        <div class='menu-section' id="field-guide">
          <h1>#{translate 'classifyMenu.content.fieldGuide'}</h1>
          <div class="guide-item kelp">
            <p>#{translate 'classifyMenu.content.kelp'}</p>
          </div>
          <div class="guide-item kelp-alt">
            <p>#{translate 'classifyMenu.content.kelp'}</p>
          </div>
          <div class="guide-item clouds">
            <p>#{translate 'classifyMenu.content.clouds'}</p>
          </div>
        </div>
        <div class='menu-section'>
          <button class='location-btn' id="all-locations">#{translate 'classifyMenu.locations.all'}</button>
          <button class='location-btn' id="california">#{translate 'classifyMenu.locations.california'}</button>
          <button class='location-btn' id="tasmania">#{translate 'classifyMenu.locations.tasmania'}</button>
        </div>
        <div class='menu-section'>
          <h1>Favorites Menu Section</h1>
        </div>
      </div>

      <div class="preload">
        <img src='./images/kelp-before1.jpg'>
        <img src='./images/kelp-before2.jpg'>
      </div>
    </div>
  """

  create: -> $(".readymade-classify-page").append(html)

  constructor: ->
    @create()
    @el = $("#classify-menu")

    @el.find(".menu-section").hide()
    @el.find(".location-btn#all-locations").addClass("selected")

    @tab = @el.find(".tab")
    @locationBtn = @el.find(".location-btn")
    @favoritesTab = @el.find("#favorites-tab")

    @tab.on "click", (e) => @onTabClick(e)
    @locationBtn.on 'click', (e) => @onChangeLocation(e)
    @favoritesTab.on 'click', => @updateFavorite()
    @el.on "new-subject", => @resetFavoriteTab()

  updateFavorite: ->
    classifyPage.classification.favorite = !classifyPage.classification.favorite
    if classifyPage.classification.favorite
      @favoritesTab.text("#{translate 'classifyMenu.tab.favorited'}").addClass("favorited")
    else
      @resetFavoriteTab()

  resetFavoriteTab: ->
    if @favoritesTab.hasClass("favorited")
      @favoritesTab.html("<img src='./icons/favorite.svg'>#{translate 'classifyMenu.tab.favorites'}").removeClass("favorited")

  onTabClick: (e) ->
    tab = e.target
    return if tab.id is 'tutorial-tab' or tab.id is 'favorites-tab'
    @displayTabSection(tab)
    @scrollToBottomOfSiteFooter()

  tabNum: (tab) -> @el.find(tab).index() + 1

  displayTabSection: (tab) ->
    section = @correspondingSectionTo(tab)
    if section.is(":visible") then @hide section else @display section

  correspondingSectionTo: (tab) ->
    @el.find(".menu-section:nth-child(#{@tabNum(tab)})")

  scrollToBottomOfSiteFooter: ->
    $("html, body").animate({ scrollTop:($("#footer-container").offset().top - window.innerHeight)}, 500)

  display: (section) ->
    @el.find(".tab:eq(#{section.index()})").addClass("active").siblings().removeClass("active")
    section.show().addClass("active").siblings().hide().removeClass("active")

  hide: (section) ->
    @el.find(".tab:eq(#{section.index()})").removeClass("active")
    section.hide()

  onChangeLocation: (e) ->
    locationName = e.target.id
    classifyPage.Subject.group = GROUPS[locationName]
    # classifyPage.Subject.next()

    # classifyPage.trigger("location-change")

    btnClicked = @el.find(e.target)
    btnClicked.addClass("selected").siblings().removeClass("selected")
    $("#location-data h2").text(btnClicked.text())

module?.exports = ClassifyMenu