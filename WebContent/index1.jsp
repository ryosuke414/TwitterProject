<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Twitter</title>
    <link href="<%=request.getContextPath()%>/static/css/style.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
</head>
<body>
    <div class="container">
        <!-- 左ナビゲーションバー -->
        <nav class="sidebar-left">
            <div class="logo">
                <h1>Twitter</h1>
            </div>
            <ul>
                <li><a href="#" class="active">ホーム</a></li>
                <li><a href="#">プロフィール</a></li>
                <li><a href="#">メッセージ</a></li>
                <li><a href="#">設定</a></li>
            </ul>
        </nav>
        <!-- メインコンテンツ -->

        <!-- メインコンテンツ（タイムライン） -->
        <main class="timeline">
            <!-- 投稿入力エリア -->
            <div class="post-form">
                <img src="https://via.placeholder.com/48" alt="User Avatar" class="avatar">
                <textarea placeholder="いま何してる？" class="post-input"></textarea>
                <button class="post-button">投稿</button>
            </div>

            <!-- 投稿一覧 -->
            <div class="posts">
                <div class="post">
                    <img src="./static/image/profile_images/inokuchi.jpg" alt="User Avatar" class="avatar">
                    <div class="post-content">
                        <div class="post-header">
                            <span class="username">猪口慎二</span>
                            <span class="handle">@inokuchi</span>
                            <span class="timestamp">・1時間前</span>
                        </div>
                        <p>授業だるい</p>
                        <div class="post-actions">
                            <span>💬 10</span>
                            <span>🔁 5</span>
                            <span>❤️ 20</span>
                        </div>
                    </div>
                </div>
                <!-- さらに投稿を追加 -->
                <div class="post">
                    <img src="https://via.placeholder.com/48" alt="User Avatar" class="avatar">
                    <div class="post-content">
                        <div class="post-header">
                            <span class="username">ユーザー名2</span>
                            <span class="handle">@handle2</span>
                            <span class="timestamp">・2時間前</span>
                        </div>
                        <p>もう一つのサンプル投稿。シンプルでモダンなデザインを目指しました。</p>
                        <div class="post-actions">
                            <span>💬 8</span>
                            <span>🔁 3</span>
                            <span>❤️ 15</span>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <!-- 右サイドバー -->
        <aside class="sidebar-right">
            <div class="search">
                <input type="text" placeholder="検索...">
            </div>
            <div class="trends">
                <h3>トレンド</h3>
                <ul>
                    <li>#石破内閣崩壊</li>
                    <li>#岸田内閣支持率急落</li>
                    <li>#パズドラサ終</li>
                </ul>
            </div>
        </aside>
    </div>
</body>
</html>